import 'dart:collection';

import '../../../model/api/api_object_property.dart';
import '../../../model/command/base_command.dart';
import '../../../model/command/ui/update_components_command.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/component/panel/fl_panel_model.dart';
import '../../../model/menu/menu_model.dart';
import '../i_storage_service.dart';
import '../../../../util/extensions/list_extensions.dart';

class ComponentStore implements IStorageService {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// MenuModel of current app.
  MenuModel? _menuModel;

  /// Map of all active components received from server, key set to id of [FlComponentModel].
  final HashMap<String, FlComponentModel> _componentMap = HashMap();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<MenuModel> getMenu() async {
    MenuModel? menuModel = _menuModel;
    if(menuModel != null){
      return menuModel;
    } else {
      throw Exception("No Menu was found");
    }
  }

  @override
  Future<bool> saveMenu(MenuModel menuModel) async {
    _menuModel = menuModel;

    return true;
  }


  @override
  Future<List<FlComponentModel>> getScreenByScreenClassName(String screenClassName) async {
    // Get Screen (Top-most Panel)
    FlComponentModel? screenModel = _componentMap.values.firstWhereOrNull((componentModel) => _isScreen(screenClassName, componentModel));

    if(screenModel != null){
      List<FlComponentModel> screen = [];

      screen.add(screenModel);
      screen.addAll(_getAllComponentsBelow(screenModel.id));
      return screen;
    }

    throw Exception("No Screen with screenClassName: $screenClassName was found");
  }

  @override
  Future<List<BaseCommand>> updateComponents(List<dynamic>? componentsToUpdate, List<FlComponentModel>? newComponents) async {

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

    for (FlComponentModel componentModel in _componentMap.values) {
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
    _componentMap[newComponent.id] = newComponent;
    newComponent;
  }

  /// Updates existing component models
  FlComponentModel _updateExistingModels(dynamic updateData){
    FlComponentModel? oldModel;
    FlComponentModel? existingComponent = _componentMap[updateData[ApiObjectProperty.id]];
    if(existingComponent != null) {
      FlComponentModel updatedComponent = existingComponent.updateComponent(existingComponent, updateData);
      _componentMap[updatedComponent.id] = updatedComponent;
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
        FlComponentModel? newModel = _componentMap[updateData[ApiObjectProperty.id]];
        FlComponentModel? oldModel = oldModels.firstWhereOrNull((element) => element.id == updateData[ApiObjectProperty.id]);
        if(newModel != null && oldModel != null){
          // Model was changed in some way
          effectedComponents.add(newModel);

          // Parent of model was changed, means all possible effected components need to retrieved as it's possible that they are not currently rendered.
          String? newParentId = updateData[ApiObjectProperty.parent];
          String? oldParentId = oldModel.parent;
          if(newParentId != oldParentId &&  newParentId != null && oldParentId != null){
            FlComponentModel oldParentModel = _componentMap[oldParentId]!;
            FlComponentModel newParentModel = _componentMap[newParentId]!;
            List<FlComponentModel> myChildren = _getAllComponentsBelow(newModel.id);
            effectedComponents.addAll([oldParentModel, newParentModel, ...myChildren]);
          }
        }


      }
    }
    return effectedComponents;
  }

}