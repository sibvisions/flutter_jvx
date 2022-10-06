import 'dart:collection';

import '../../../../../flutter_jvx.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/ui/update_components_command.dart';
import '../../../../model/component/fl_component_model.dart';
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
  List<BaseCommand> saveComponents(
    List<dynamic>? componentsToUpdate,
    List<FlComponentModel>? newComponents,
    String screenName,
  ) {
    // List of all changed models
    Set<String> changedModels = {};
    // List of all affected models
    Set<String> affectedModels = {};

    List<FlComponentModel> oldScreenComps = _getAllComponentsBelowByName(name: screenName, ignoreVisibility: false);

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
          _componentMap[removedModel.id] = removedModel;
          _removedComponents.remove(removedModel.id);
        }

        // Get old Model
        FlComponentModel? model = _componentMap[changedData[ApiObjectProperty.id]];
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
          if (model.isRemoved) {
            _componentMap.remove(model.id);
            _removedComponents[model.id] = model;
          }

          // Handle parent change, notify old parent of change
          if (oldParentId != null && model.parent != oldParentId) {
            FlComponentModel oldParent = _componentMap[oldParentId]!;
            affectedModels.add(oldParent.id);
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
    Set<String> deletedUiComponents = {};
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
        bool isChanged = changedUiComponents.any((changedModel) => changedModel.id == affectedModel);
        bool isNew = newUiComponents.any((newModel) => newModel.id == affectedModel);
        if (!isChanged && !isNew) {
          affectedUiComponents.add(affectedModel);
        }
      }
    }

    FlutterJVx.log.d("----------DeletedUiComponents: $deletedUiComponents ");
    FlutterJVx.log.d("----------affected: $affectedUiComponents ");
    FlutterJVx.log.d("----------changed: $changedUiComponents ");
    FlutterJVx.log.d("----------newUiComponents: $newUiComponents ");

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
    FlutterJVx.log.d("Deleting Screen: $screenName, current is: _componentMap: ${_componentMap.length}");

    FlutterJVx.log.d(_componentMap.keys.toList().toString());

    var list = _componentMap.values.where((componentModel) => componentModel.name == screenName).toList();

    for (var screenModel in list) {
      _componentMap.remove(screenModel.id);

      List<FlComponentModel> models = _getAllComponentsBelow(screenModel.id, true);
      models.forEach((element) {
        _componentMap.remove(element.id);
      });
    }

    FlutterJVx.log.d("Deleted Screen: $screenName, current is: _componentMap: ${_componentMap.length}");
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns List of all [FlComponentModel] below it, recursively.
  List<FlComponentModel> _getAllComponentsBelow(String id, [bool ignoreVisibility = false]) {
    List<FlComponentModel> children = [];

    for (FlComponentModel componentModel in _componentMap.values) {
      String? parentId = componentModel.parent;
      if (parentId != null && parentId == id && (ignoreVisibility || componentModel.isVisible)) {
        children.add(componentModel);
        children.addAll(_getAllComponentsBelow(componentModel.id));
      }
    }
    return children;
  }

  List<FlComponentModel> _getAllComponentsBelowByName({required String name, bool ignoreVisibility = false}) {
    FlComponentModel? componentModel;
    _componentMap.forEach((key, value) {
      if (value.name == name) {
        componentModel = value;
      }
    });

    if (componentModel != null && (ignoreVisibility || componentModel!.isVisible)) {
      var list = _getAllComponentsBelow(componentModel!.id, ignoreVisibility);
      list.add(componentModel!);
      return list;
    } else {
      return [];
    }
  }

  /// Adds new Component
  void _addNewComponent(FlComponentModel newComponent) {
    _componentMap[newComponent.id] = newComponent;
  }
}
