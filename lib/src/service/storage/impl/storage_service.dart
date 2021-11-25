import 'dart:collection';
import 'dart:developer';

import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/ui/update_components_command.dart';

import '../../../model/api/api_object_property.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/component/panel/fl_panel_model.dart';
import '../../../model/menu/menu_model.dart';
import '../i_storage_service.dart';
import '../../../../util/extensions/list_extensions.dart';

/// Contains all component & menu Data
// Author: Michael Schober
class StorageService implements IStorageService {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// MenuModel of current app.
  MenuModel? _menuModel;

  /// Map of all active components received from server, key set to id of [FlComponentModel].
  HashMap<String, FlComponentModel> componentMap = HashMap();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  MenuModel? getMenu() {
    return _menuModel;
  }

  @override
  void saveMenu(MenuModel menuModel) {
    _menuModel = menuModel;
  }


  @override
  List<FlComponentModel>? getScreenByScreenClassName(String screenClassName) {
    // Get Screen (Top-most Panel)
    FlComponentModel? screenModel = componentMap.values.firstWhereOrNull((componentModel) => _isScreen(screenClassName, componentModel));

    if(screenModel != null){
      List<FlComponentModel> screen = [];

      screen.add(screenModel);
      screen.addAll(_getAllComponentsBelow(screenModel.id));
      return screen;
    }
    return null;
  }

  @override
  List<BaseCommand> updateComponents(List<dynamic>? componentsToUpdate, List<FlComponentModel>? newComponents) {

    List<FlComponentModel> oldModels = [];
    List<BaseCommand> commands = [];

    // Handle new Components
    if(newComponents != null){
      for(FlComponentModel componentModel in newComponents){
        _addNewComponent(componentModel);
      }
    }

    // Handle components to Update
    if(componentsToUpdate != null){
      for(dynamic changedData in componentsToUpdate){
        oldModels.add(_updateExistingModels(changedData));
      }
    }
    List<FlComponentModel> effectedComponents = _getEffectedComponentModels(componentsToUpdate, newComponents, oldModels);

    UpdateComponentsCommand command = UpdateComponentsCommand(
        affectedComponents: effectedComponents,
        reason: "Components have been updated"
    );
    commands.add(command);
    return commands;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns true if [componentModel] does have the [ApiObjectProperty.screenClassName] property
  /// and it matches the [screenClassName]
  bool _isScreen(String screenClassName, FlComponentModel componentModel) {
    FlPanelModel? componentPanelModel;

    if(componentModel is FlPanelModel){
      componentPanelModel = componentModel;
    }

    if(componentPanelModel != null) {
      if(componentPanelModel.screenClassName == screenClassName) {
        return true;
      }
    }
    return false;
  }

  /// Returns List of all [FlComponentModel] below it, recursively.
  List<FlComponentModel> _getAllComponentsBelow(String id) {
    List<FlComponentModel> children = [];

    for (FlComponentModel componentModel in componentMap.values) {
      String? parentId = componentModel.parent;
      if(parentId != null && parentId == id){
        children.add(componentModel);
        children.addAll(_getAllComponentsBelow(componentModel.id));
      }
    }
    return children;
  }


  /// Adds new Component
  void _addNewComponent(FlComponentModel newComponent){
    componentMap[newComponent.id] = newComponent;
    newComponent;
  }

  /// Updates existing component models
  FlComponentModel _updateExistingModels(dynamic updateData){
    FlComponentModel? oldModel;
    FlComponentModel? existingComponent = componentMap[updateData[ApiObjectProperty.id]];
    if(existingComponent != null) {
      FlComponentModel updatedComponent = existingComponent.updateComponent(existingComponent, updateData);
      componentMap[updatedComponent.id] = updatedComponent;
      oldModel = existingComponent;
    }
    if(oldModel != null){
      return oldModel;
    } else {
      throw Exception("asdasd");
    }

  }

  /// Returns all affected ComponentModel, called after [_addNewComponent] and [_updateExistingModels]
  List<FlComponentModel> _getEffectedComponentModels(List<dynamic>? componentsToUpdate, List<FlComponentModel>? newComponents, List<FlComponentModel>? oldModels){
    List<FlComponentModel> effectedComponents = [];


    if(newComponents != null){
      effectedComponents.addAll(newComponents);
    }

    if(componentsToUpdate != null && oldModels != null){
      for(dynamic updateData in componentsToUpdate){
        FlComponentModel? newModel = componentMap[updateData[ApiObjectProperty.id]];
        FlComponentModel? oldModel = oldModels.firstWhereOrNull((element) => element.id == updateData[ApiObjectProperty.id]);
        if(newModel != null && oldModel != null){
          // Model was changed in some way
          effectedComponents.add(newModel);

          // Parent of model was changed, means all possible effected components need to retrieved as it's possible that they are not currently rendered.
          String? newParentId = updateData[ApiObjectProperty.parent];
          String? oldParentId = oldModel.parent;
          if(newParentId != oldParentId &&  newParentId != null && oldParentId != null){
            FlComponentModel oldParentModel = componentMap[oldParentId]!;
            FlComponentModel newParentModel = componentMap[newParentId]!;
            List<FlComponentModel> myChildren = _getAllComponentsBelow(newModel.id);
            effectedComponents.addAll([oldParentModel, newParentModel, ...myChildren]);
          }
        }


      }
    }
    return effectedComponents;
  }
}