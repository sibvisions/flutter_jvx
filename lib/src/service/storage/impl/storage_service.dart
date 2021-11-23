import 'dart:collection';

import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/component/fl_component_model.dart';
import 'package:flutter_client/src/model/component/panel/fl_panel_model.dart';
import 'package:flutter_client/src/model/menu/menu_model.dart';
import 'package:flutter_client/src/service/storage/i_storage_service.dart';

class StorageService implements IStorageService {

  MenuModel _menuModel = MenuModel();
  HashMap<String, FlComponentModel> componentMap = HashMap();



  @override
  MenuModel getMenu() {
    return _menuModel;
  }

  @override
  void saveMenu(MenuModel menuModel) {
    _menuModel = menuModel;
  }

  @override
  void saveComponent(List<FlComponentModel> components) {
    for(FlComponentModel componentModel in components){
      if(componentMap.containsKey(componentModel.id)){
        //Todo implement Component Update
      } else {
        componentMap[componentModel.id] = componentModel;
      }
    }
  }

  @override
  List<FlComponentModel> getScreenByScreenClassName(String screenClassName) {

    //First Model is Screen Panel
    List<FlComponentModel> screen = [];


    // Only Panels can be screens, no need to check any other
    try{
      // Get Screen (Top-most Panel)
      FlComponentModel screenModel = componentMap.values.firstWhere((componentModel) => _isScreen(screenClassName, componentModel) );
      // Get All Components in Screen
      screen.add(screenModel);
      screen.addAll(_getAllComponentsBelow(screenModel.id));
    } catch (e) {
      throw Exception("No Screen corresponding to ScreenClassName: $screenClassName was found");
    }
    return screen;
  }

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

  /// Gets all components below it
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

}