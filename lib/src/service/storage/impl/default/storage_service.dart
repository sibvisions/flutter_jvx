import 'dart:collection';

import '../../../../../util/extensions/list_extensions.dart';
import '../../../../../util/logging/flutter_logger.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/ui/update_components_command.dart';
import '../../../../model/component/fl_component_model.dart';
import '../../../../model/component/panel/fl_panel_model.dart';
import '../../../api/shared/api_object_property.dart';
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

  @override
  Future<List<FlComponentModel>> getScreenByScreenClassName(String screenClassName) async {
    // Get Screen (Top-most Panel)
    FlComponentModel? screenModel =
        _componentMap.values.firstWhereOrNull((componentModel) => _isScreen(screenClassName, componentModel));

    if (screenModel != null) {
      List<FlComponentModel> screen = [];

      screen.add(screenModel);
      screen.addAll(_getAllComponentsBelow(screenModel.id));
      return screen;
    }

    throw Exception("No Screen with screenClassName: $screenClassName was found");
  }

  @override
  Future<List<BaseCommand>> updateComponents(
    List<dynamic>? componentsToUpdate,
    List<FlComponentModel>? newComponents,
    String screenName,
  ) async {
    // List of all changed models
    Set<String> changedModels = {};
    // List of all affected models
    Set<String> affectedModels = {};

    List<FlComponentModel> oldScreenComps = _getAllComponentsBelowByName(name: screenName);

    // Handle new Components
    if (newComponents != null) {
      for (FlComponentModel componentModel in newComponents) {
        // Notify parent that a new component has been added.
        String? parentId = componentModel.parent;
        if (parentId != null) {
          affectedModels.add(parentId);
        }
        _addNewComponent(componentModel);
      }
    }

    // Handle components to Update
    if (componentsToUpdate != null) {
      for (Map<String, dynamic> changedData in componentsToUpdate) {
        // If a removed component changes it is no longer removed
        FlComponentModel? removedModel = _removedComponents[changedData[ApiObjectProperty.id]];
        if (removedModel != null) {
          removedModel.isRemoved = false;
          _componentMap[removedModel.id] = removedModel;
        }

        // Get old Model
        FlComponentModel? model = _componentMap[changedData[ApiObjectProperty.id]];
        if (model != null) {
          // Update Component and add to changedModels
          String? oldParentId = model.parent;
          bool wasVisible = model.isVisible;

          model.lastChangedProperties = changedData.keys.toSet();
          model.applyFromJson(changedData);
          changedModels.add(model.id);

          // Handle component removed
          if (model.isRemoved) {
            _componentMap.remove(model.id);
            _removedComponents[model.id] = model;
          } else {
            _componentMap[model.id] = model;
          }

          // Handle parent change, notify old parent of change
          if (model.parent != oldParentId) {
            var oldParent = _componentMap[model.parent]!;
            affectedModels.add(oldParent.id);
          }

          if (model.isVisible != wasVisible || model.isRemoved) {
            affectedModels.add(model.parent!);
          }
        }
      }
    }

    List<FlComponentModel> newScreenComps = _getAllComponentsBelowByName(name: screenName);

    List<FlComponentModel> newUiComponents = [];
    List<FlComponentModel> changedUiComponents = [];
    Set<String> deletedUiComponents = {};
    Set<String> affectedUiComponents = {};

    // Build UI Notification
    // Check for new or changed active components
    for (FlComponentModel newModel in newScreenComps) {
      // Was model already sent once, present in oldScreen
      bool isExisting = oldScreenComps.isNotEmpty && oldScreenComps.any((oldModel) => oldModel.id == newModel.id);

      // IF component has not been rendered before it is new.
      if (!isExisting) {
        newUiComponents.add(newModel);
      } else {
        // IF component has been rendered, check if it has been changed.
        bool hasChanged = changedModels.any((changedModels) => changedModels == newModel.id);
        if (hasChanged) {
          changedUiComponents.add(newModel);
        }
      }
    }

    // Check for components which are not active anymore, e.g. not visible, removed or destroyed
    for (FlComponentModel oldModel in oldScreenComps) {
      bool isExisting = newScreenComps.any((newModel) => newModel.id == oldModel.id);

      if (!isExisting) {
        deletedUiComponents.add(oldModel.id);
      }
    }

    // Components can only be affected if any other component has either changed, was deleted or is new. -Special Case for opening a screen
    // Only add Models to affected if they are not new or changed, to avoid unnecessary re-renders.
    if (newUiComponents.isNotEmpty || changedUiComponents.isNotEmpty || deletedUiComponents.isNotEmpty) {
      for (String affectedModel in affectedModels) {
        bool isChanged = changedUiComponents.any((changedModel) => changedModel.id == affectedModel);
        bool isNew = newUiComponents.any((newModel) => newModel.id == affectedModel);
        if (!isChanged && !isNew) {
          affectedUiComponents.add(affectedModel);
        }
      }
    }

    // log("----------DeletedUiComponents: $deletedUiComponents ");
    // log("----------affected: $affectedUiComponents ");
    // log("----------changed: $changedUiComponents ");
    // log("----------newUiComponents: $newUiComponents ");

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
  Future<void> deleteScreen({required String screenName}) async {
    LOGGER.logD(
        pType: LOG_TYPE.STORAGE,
        pMessage: "Deleting Screen: $screenName, current is: _componentMap: ${_componentMap.length}");

    LOGGER.logD(pType: LOG_TYPE.STORAGE, pMessage: _componentMap.keys.toList().toString());

    FlComponentModel? screenModel =
        _componentMap.values.firstWhereOrNull((componentModel) => componentModel.name == screenName);

    if (screenModel != null) {
      _componentMap.remove(screenModel.id);

      List<FlComponentModel> models = _getAllComponentsBelow(screenModel.id, true);
      models.forEach((element) {
        _componentMap.remove(element.id);
      });
    }
    LOGGER.logD(
        pType: LOG_TYPE.STORAGE,
        pMessage: "Deleted Screen: $screenName, current is: _componentMap: ${_componentMap.length}");
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns true if [componentModel] does have the [ApiObjectProperty.screenClassName] property
  /// and it matches the [screenClassName]
  bool _isScreen(String screenClassName, FlComponentModel componentModel) {
    FlPanelModel? componentPanelModel;

    if (componentModel is FlPanelModel) {
      componentPanelModel = componentModel;
    }

    if (componentPanelModel != null) {
      if (componentPanelModel.screenClassName == screenClassName) {
        return true;
      }
    }
    return false;
  }

  /// Returns List of all [FlComponentModel] below it, recursively.
  List<FlComponentModel> _getAllComponentsBelow(String id, [bool ignoreVisiblity = false]) {
    List<FlComponentModel> children = [];

    for (FlComponentModel componentModel in _componentMap.values) {
      String? parentId = componentModel.parent;
      if (parentId != null && (ignoreVisiblity || parentId == id && componentModel.isVisible)) {
        children.add(componentModel);
        children.addAll(_getAllComponentsBelow(componentModel.id));
      }
    }
    return children;
  }

  List<FlComponentModel> _getAllComponentsBelowByName({required String name, bool ignoreVisiblity = false}) {
    FlComponentModel? componentModel;
    _componentMap.forEach((key, value) {
      if (value.name == name) {
        componentModel = value;
      }
    });

    if (componentModel != null && (ignoreVisiblity || componentModel!.isVisible)) {
      var list = _getAllComponentsBelow(componentModel!.id, ignoreVisiblity);
      list.add(componentModel!);
      return list;
    } else {
      return [];
    }
  }

  /// Adds new Component
  void _addNewComponent(FlComponentModel newComponent) {
    _componentMap[newComponent.id] = newComponent;
    newComponent;
  }
}
