import 'dart:collection';
import 'dart:developer';

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
  void saveComponent(List<FlComponentModel> components) {
    for(FlComponentModel componentModel in components){
      if(componentMap.containsKey(componentModel.id)){
        var a = componentModel.updateComponent(componentMap[componentModel.id]!, componentModel);
        log(a.toString());
      } else {
        // log(componentModel.toString());
        componentMap[componentModel.id] = componentModel;
      }
    }
  }

  @override
  void updateComponent(List<dynamic> components) {
    List<FlComponentModel> affectedComponents = [];
    for(dynamic component in components) {
      FlComponentModel? componentModel = componentMap[component[ApiObjectProperty.id]];
      if(componentModel != null){
        FlComponentModel updatedComponent = componentModel.updateComponent(componentModel, component);
        componentMap[updatedComponent.id] = updatedComponent;
        affectedComponents.add(updatedComponent);

        // Parent Changed, add all components below new one and add old model, as all of them are affected by this update
        String? oldParent = componentModel.parent;
        String? newParent = updatedComponent.parent;
        if(oldParent != newParent && oldParent != null && newParent != null){
          List<FlComponentModel> belowNewParent = _getAllComponentsBelow(newParent);
          FlComponentModel old = componentMap[oldParent]!;
          affectedComponents.addAll(belowNewParent);
          affectedComponents.add(old);
        }
      }
    }
    affectedComponents.
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



}