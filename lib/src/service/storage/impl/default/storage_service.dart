import 'dart:collection';

import 'package:collection/collection.dart';

import '../../../../flutter_ui.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/ui/update_components_command.dart';
import '../../../../model/component/fl_component_model.dart';
import '../../../../model/component/panel/fl_panel_model.dart';
import '../../../api/shared/api_object_property.dart';
import '../../../api/shared/fl_component_classname.dart';
import '../../i_storage_service.dart';

class StorageService implements IStorageService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Map of all active components received from server, key set to id of [FlComponentModel].
  final HashMap<String, FlComponentModel> _componentMap = HashMap();

  /// Map of the component tree for faster traversal.
  final HashMap<String, Set<String>> _childrenTree = HashMap();
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  StorageService.create();

  @override
  void clear() {
    _componentMap.clear();
    _childrenTree.clear();
  }

  @override
  List<BaseCommand> saveComponents(
    List<dynamic>? componentsToUpdate,
    List<FlComponentModel>? newComponents,
    String screenName,
  ) {
    if ((componentsToUpdate == null || componentsToUpdate.isEmpty) &&
        (newComponents == null || newComponents.isEmpty)) {
      return [];
    }

    // List of all changed models
    Set<String> changedModels = {};
    // List of all affected models
    Set<String> affectedModels = {};

    Set<FlComponentModel> destroyedOrRemovedModels = {};

    List<FlComponentModel> oldScreenComps = getAllComponentsBelowByName(name: screenName);

    // Handle new Components
    if (newComponents != null) {
      for (FlComponentModel componentModel in newComponents) {
        // Notify parent that a new component has been added.
        String? parentId = componentModel.parent;
        if (parentId != null) {
          affectedModels.add(parentId);
        }
        _componentMap[componentModel.id] = componentModel;
        _addAsChild(componentModel);
      }
    }

    // Handle components to Update
    if (componentsToUpdate != null) {
      for (Map<String, dynamic> changedData in componentsToUpdate) {
        String changedId = changedData[ApiObjectProperty.id];

        // Get old Model
        FlComponentModel? model = _componentMap[changedId];
        if (model != null) {
          // Update Component and add to changedModels
          String? oldParentId = model.parent;
          bool wasVisible = model.isVisible;
          bool wasRemoved = model.isRemoved;
          model.isRemoved = false;

          model.lastChangedProperties = changedData.keys.toSet();
          _removeAsChild(model);
          model.applyFromJson(changedData);
          if (model.isDestroyed) {
            _componentMap.remove(model.id);
          }
          {
            _addAsChild(model);
          }
          changedModels.add(model.id);

          // Handle component removed
          if (model.isDestroyed || model.isRemoved) {
            destroyedOrRemovedModels.add(model);
          }

          // Handle parent change, notify old parent of change
          if (oldParentId != null && model.parent != oldParentId) {
            FlComponentModel? oldParent = _componentMap[oldParentId];
            if (oldParent != null) {
              affectedModels.add(oldParent.id);
            }
          }

          if (model.isVisible != wasVisible || model.isRemoved != wasRemoved) {
            affectedModels.add(model.parent!);
          }
        }
      }
    }

    List<FlComponentModel> currentScreenComps = getAllComponentsBelowByName(name: screenName);

    List<FlComponentModel> newUiComponents = [];
    List<String> changedUiComponents = [];
    Set<String> deletedUiComponents = {...destroyedOrRemovedModels.map((e) => e.id)};
    Set<String> affectedUiComponents = {};

    // Build UI Notification
    // Check for new or changed active components
    for (FlComponentModel currentModel in currentScreenComps) {
      // Was model already sent once, present in oldScreen
      bool isExisting = oldScreenComps.isNotEmpty && oldScreenComps.any((oldModel) => oldModel.id == currentModel.id);

      // IF component has not been rendered before it is new.
      if (!isExisting) {
        newUiComponents.add(currentModel);
      } else {
        // IF component has been rendered, check if it has been changed.
        bool hasChanged = changedModels.any((changedModels) => changedModels == currentModel.id);
        // If model has been changed and is still in the screen.
        if (hasChanged) {
          changedUiComponents.add(currentModel.id);
        }
      }
    }

    // Check for components which are not active anymore, e.g. not visible, removed or destroyed
    for (FlComponentModel oldModel in oldScreenComps) {
      bool isExisting = currentScreenComps.any((newModel) => newModel.id == oldModel.id);

      if (!isExisting) {
        deletedUiComponents.add(oldModel.id);
      }
    }

    // Components can only be affected if any other component has either changed, was deleted or is new.
    if (newUiComponents.isNotEmpty || changedUiComponents.isNotEmpty || deletedUiComponents.isNotEmpty) {
      // Only add Models to affected if they are not new or changed, to avoid unnecessary re-renders.
      for (String affectedModel in affectedModels) {
        bool isExisting = oldScreenComps.any((oldModel) => oldModel.id == affectedModel);
        bool isChanged = changedUiComponents.any((changedModel) => changedModel == affectedModel);
        bool isNew = newUiComponents.any((newModel) => newModel.id == affectedModel);
        if (!isChanged && !isNew && isExisting) {
          affectedUiComponents.add(affectedModel);
        }
      }
    }

    FlutterUI.logUI.d("DeletedUiComponents {${deletedUiComponents.length}}:${deletedUiComponents.toList()..sort()}");
    FlutterUI.logUI.d("Affected {${affectedUiComponents.length}}:${affectedUiComponents.toList()..sort()}");
    FlutterUI.logUI.d("Changed {${changedUiComponents.length}}:${changedUiComponents.toList()..sort()}");
    FlutterUI.logUI
        .d("NewUiComponents {${newUiComponents.length}}:${newUiComponents.map((e) => e.id).toList()..sort()}");

    UpdateComponentsCommand updateComponentsCommand = UpdateComponentsCommand(
      affectedComponents: affectedUiComponents,
      changedComponents: changedUiComponents,
      deletedComponents: deletedUiComponents,
      reason: "Server Changed Components",
    );

    return [updateComponentsCommand];
  }

  @override
  void deleteScreen({required String screenName}) {
    FlutterUI.logUI.d("Deleting Screen: $screenName, current is: _componentMap: ${_componentMap.length}");

    FlutterUI.logUI.d(_componentMap.keys.toList().toString());

    var list = _componentMap.values.where((componentModel) => componentModel.name == screenName).toList();

    for (var screenModel in list) {
      _componentMap.remove(screenModel.id);
      _childrenTree.remove(screenModel.id);

      List<FlComponentModel> models = getAllComponentsBelow(
        pParentModel: screenModel,
        pIgnoreVisibility: true,
        pIncludeRemoved: true,
      );
      models.forEach((element) {
        _componentMap.remove(element.id);
        _childrenTree.remove(element.id);
      });
    }

    FlutterUI.logUI.d("Deleted Screen: $screenName, current is: _componentMap: ${_componentMap.length}");
  }

  @override
  List<FlComponentModel> getAllComponentsBelow(
      {required FlComponentModel pParentModel,
      bool pIgnoreVisibility = false,
      bool pIncludeRemoved = false,
      bool pRecursively = true}) {
    List<FlComponentModel> allDescendants = [];
    Set<String> directChildren = _childrenTree[pParentModel.id] ?? {};

    for (String childId in directChildren) {
      FlComponentModel? childModel = _componentMap[childId];
      if (childModel != null && !pIncludeRemoved && childModel.isRemoved) {
        childModel = null;
      }
      // Tabsetpanels set non selected sub-panels as invisible.
      // We always render them though, even the invisible panels,
      // therefore tabset-children are always visible for us.
      if (childModel != null &&
          (pIgnoreVisibility || childModel.isVisible || pParentModel.className == FlContainerClassname.TABSET_PANEL)) {
        allDescendants.add(childModel);
        if (pRecursively) {
          allDescendants.addAll(
            getAllComponentsBelow(
              pParentModel: childModel,
              pIgnoreVisibility: pIgnoreVisibility,
              pIncludeRemoved: pIncludeRemoved,
              pRecursively: pRecursively,
            ),
          );
        }
      }
    }

    return allDescendants;
  }

  @override
  List<FlComponentModel> getAllComponentsBelowByName(
      {required String name, bool pIgnoreVisibility = false, bool pIncludeRemoved = false, bool pRecursively = true}) {
    List<FlComponentModel> list = [];
    List<FlComponentModel> screenModels = _componentMap.values.where((element) => element.name == name).toList();

    if (screenModels.length >= 2) {
      FlutterUI.logUI.wtf("The same screen is found twice in the storage service!!!!");
    } else if (screenModels.length == 1 && (pIgnoreVisibility || screenModels.first.isVisible)) {
      list.addAll(getAllComponentsBelow(
          pParentModel: screenModels.first,
          pIgnoreVisibility: pIgnoreVisibility,
          pIncludeRemoved: pIncludeRemoved,
          pRecursively: pRecursively));
    }

    return list;
  }

  @override
  List<FlComponentModel> getAllComponentsBelowById(
      {required String pParentId,
      bool pIgnoreVisibility = false,
      bool pIncludeRemoved = false,
      bool pRecursively = true}) {
    List<FlComponentModel> list = [];
    List<FlComponentModel> screenModels = _componentMap.values.where((element) => element.id == pParentId).toList();

    if (screenModels.length >= 2) {
      FlutterUI.logUI.wtf("The same screen is found twice in the storage service!!!!");
    } else if (screenModels.length == 1 && (pIgnoreVisibility || screenModels.first.isVisible)) {
      list.addAll(getAllComponentsBelow(
          pParentModel: screenModels.first,
          pIgnoreVisibility: pIgnoreVisibility,
          pIncludeRemoved: pIncludeRemoved,
          pRecursively: pRecursively));
    }

    return list;
  }

  @override
  FlComponentModel? getComponentModel({required String pComponentId}) {
    return _componentMap[pComponentId];
  }

  @override
  FlComponentModel? getComponentByName({required String pComponentName}) {
    return _componentMap.values.firstWhereOrNull((element) => element.name == pComponentName);
  }

  @override
  FlPanelModel? getComponentByScreenClassName({required String pScreenClassName}) {
    return _componentMap.values
        .whereType<FlPanelModel>()
        .firstWhereOrNull((element) => element.screenClassName == pScreenClassName);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  _addAsChild(FlComponentModel pChild) {
    if (pChild.parent != null && pChild.parent!.isNotEmpty) {
      Set<String> children = _childrenTree[pChild.parent] ?? {};
      children.add(pChild.id);
      _childrenTree[pChild.parent!] = children;
    }
  }

  _removeAsChild(FlComponentModel pChild) {
    if (pChild.parent != null && pChild.parent!.isNotEmpty) {
      Set<String> children = _childrenTree[pChild.parent] ?? {};
      children.remove(pChild.id);
      _childrenTree[pChild.parent!] = children;
    }
  }
}
