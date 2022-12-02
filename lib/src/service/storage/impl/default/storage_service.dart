import 'dart:collection';

import '../../../../../flutter_jvx.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/ui/update_components_command.dart';
import '../../../../model/component/fl_component_model.dart';
import '../../../api/shared/api_object_property.dart';
import '../../../api/shared/fl_component_classname.dart';
import '../../i_storage_service.dart';

class StorageService implements IStorageService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Map of all active components received from server, key set to id of [FlComponentModel].
  final HashMap<String, FlComponentModel> _componentMap = HashMap();

  /// Map of all components with "[ApiObjectProperty.remove]" flag to true, these components are not yet to be deleted.
  final HashMap<String, FlComponentModel> _removedComponents = HashMap();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  StorageService.create();

  @override
  void clear() {
    _componentMap.clear();
    _removedComponents.clear();
  }

  @override
  List<BaseCommand> saveComponents(
    List<dynamic>? componentsToUpdate,
    List<FlComponentModel>? newComponents,
    String screenName,
  ) {
    // List of all changed models
    Set<String> changedModels = {};
    // List of all affected models
    Set<String> affectedModels = {};

    Set<String> destroyedOrRemovedModels = {};

    List<FlComponentModel> oldScreenComps = _getAllComponentsBelowByName(name: screenName, ignoreVisibility: false);

    // Handle new Components
    if (newComponents != null) {
      for (FlComponentModel componentModel in newComponents) {
        // Notify parent that a new component has been added.
        String? parentId = componentModel.parent;
        if (parentId != null) {
          affectedModels.add(parentId);
        }
        _componentMap[componentModel.id] = componentModel;
      }
    }

    // Handle components to Update
    if (componentsToUpdate != null) {
      for (Map<String, dynamic> changedData in componentsToUpdate) {
        String changedId = changedData[ApiObjectProperty.id];

        // If a removed component changes it is no longer removed
        FlComponentModel? removedModel = _removedComponents[changedId];
        if (removedModel != null) {
          _componentMap[removedModel.id] = removedModel;
          _removedComponents.remove(removedModel.id);
        }

        // Get old Model
        FlComponentModel? model = _componentMap[changedId];
        if (model != null) {
          // Update Component and add to changedModels
          String? oldParentId = model.parent;
          bool wasVisible = model.isVisible;
          bool wasRemoved = model.isRemoved;
          model.isRemoved = false;

          model.lastChangedProperties = changedData.keys.toSet();
          model.applyFromJson(changedData);
          changedModels.add(model.id);

          // Handle component removed
          if (model.isDestroyed || model.isRemoved) {
            _componentMap.remove(model.id);
            if (model.isRemoved) {
              _removedComponents[model.id] = model;
            }
            destroyedOrRemovedModels.add(model.id);
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

    List<FlComponentModel> currentScreenComps = _getAllComponentsBelowByName(name: screenName, ignoreVisibility: false);

    List<FlComponentModel> newUiComponents = [];
    List<FlComponentModel> changedUiComponents = [];
    Set<String> deletedUiComponents = {...destroyedOrRemovedModels};
    Set<String> affectedUiComponents = {};

    for (String remDelId in destroyedOrRemovedModels) {
      deletedUiComponents.addAll(_getAllComponentsBelow(remDelId).map((e) => e.id));
    }

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
          changedUiComponents.add(currentModel);
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
        bool isChanged = changedUiComponents.any((changedModel) => changedModel.id == affectedModel);
        bool isNew = newUiComponents.any((newModel) => newModel.id == affectedModel);
        if (!isChanged && !isNew && isExisting) {
          affectedUiComponents.add(affectedModel);
        }
      }
    }

    FlutterJVx.logUI.d("DeletedUiComponents {${deletedUiComponents.length}}:${deletedUiComponents.toList()..sort()}");
    FlutterJVx.logUI.d("Affected {${affectedUiComponents.length}}:${affectedUiComponents.toList()..sort()}");
    FlutterJVx.logUI
        .d("Changed {${changedUiComponents.length}}:${changedUiComponents.map((e) => e.id).toList()..sort()}");
    FlutterJVx.logUI
        .d("NewUiComponents {${newUiComponents.length}}:${newUiComponents.map((e) => e.id).toList()..sort()}");

    UpdateComponentsCommand updateComponentsCommand = UpdateComponentsCommand(
      affectedComponents: affectedUiComponents,
      changedComponents: changedUiComponents,
      deletedComponents: deletedUiComponents,
      newComponents: newUiComponents,
      reason: "Server Changed Components",
    );

    return [updateComponentsCommand];
  }

  @override
  void deleteScreen({required String screenName}) {
    FlutterJVx.logUI.d("Deleting Screen: $screenName, current is: _componentMap: ${_componentMap.length}");

    FlutterJVx.logUI.d(_componentMap.keys.toList().toString());

    var list = _componentMap.values.where((componentModel) => componentModel.name == screenName).toList();

    for (var screenModel in list) {
      _componentMap.remove(screenModel.id);

      List<FlComponentModel> models = _getAllComponentsBelow(screenModel.id, true, true);
      models.forEach((element) {
        _componentMap.remove(element.id);
        _removedComponents.remove(element.id);
      });
    }

    FlutterJVx.logUI.d("Deleted Screen: $screenName, current is: _componentMap: ${_componentMap.length}");
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns List of all [FlComponentModel] below it, recursively.
  List<FlComponentModel> _getAllComponentsBelow(String id,
      [bool ignoreVisibility = false, bool includeRemoved = false]) {
    List<FlComponentModel> children = [];

    List<FlComponentModel> toCheck = _componentMap.values.toList();

    if (includeRemoved) {
      toCheck.addAll(_removedComponents.values);
    }

    for (FlComponentModel componentModel in toCheck) {
      String? parentId = componentModel.parent;
      FlComponentModel? parentModel = _componentMap[parentId];
      if (parentId != null &&
          parentId == id &&
          (ignoreVisibility ||
              componentModel.isVisible ||
              (parentModel?.className == FlContainerClassname.TABSET_PANEL))) {
        children.add(componentModel);
        children.addAll(_getAllComponentsBelow(componentModel.id, ignoreVisibility, includeRemoved));
      }
    }
    return children;
  }

  List<FlComponentModel> _getAllComponentsBelowByName(
      {required String name, bool ignoreVisibility = false, bool includeRemoved = false}) {
    List<FlComponentModel> list = [];
    List<FlComponentModel> screenModels = _componentMap.values.where((element) => element.name == name).toList();

    if (screenModels.length >= 2) {
      FlutterJVx.logUI.wtf("The same screen is found twice in the storage service!!!!");
    } else if (screenModels.length == 1 && (ignoreVisibility || screenModels.first.isVisible)) {
      list.addAll(_getAllComponentsBelow(screenModels.first.id, ignoreVisibility, includeRemoved));
      //Return after the first was found.
      list.add(screenModels.first);
    }

    return list;
  }
}
