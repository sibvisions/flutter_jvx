import 'package:flutter_jvx/src/models/api/component/panel/ui_panel_model.dart';
import 'package:flutter_jvx/src/models/api/component/ui_component_model.dart';
import 'package:flutter_jvx/src/services/component/i_component_store_service.dart';

class ComponentStoreService implements IComponentStoreService {


  final List<UiComponentModel> components = [];
  final List<UiComponentModel> removedComponents = [];

  @override
  void saveComponent(UiComponentModel componentModel) {
    if(!components.any((element) => element.id == componentModel.id)){
      components.add(componentModel);
    }
  }

  @override
  void deleteComponentById(String id) {
    // TODO: implement deleteComponentById
  }

  @override
  void removeComponentById(String id) {
    // TODO: implement removeComponentById
  }

  @override
  UiComponentModel? getComponentById(String id) {
    UiComponentModel model;
    model = components.firstWhere((element) => element.id == id);
    return model;
  }

  @override
  List<UiComponentModel> getChildrenById(String id) {
    // TODO: implement getChildrenById
    throw UnimplementedError();
  }

  @override
  UiComponentModel? getScreenByScreenClassName(String screenClassName) {
    bool compareScreenClassName(UiComponentModel model){
      UiPanelModel panelModel = model as UiPanelModel;
      if(panelModel.screenClassName == screenClassName){
        return true;
      }
      return false;
    }

    UiComponentModel? screen;
    screen = components.firstWhere(compareScreenClassName);
    return screen;
  }

  @override
  void activateRemovedComponentById(String id) {
    // TODO: implement activateRemovedComponentById
  }

  @override
  bool doesComponentExistById(String id) {
    // TODO: implement doesComponentExistById
    throw UnimplementedError();
  }

  @override
  bool isComponentRemovedById(String id) {
    // TODO: implement isComponentRemovedById
    throw UnimplementedError();
  }

  @override
  void updateComponent(UiComponentModel componentModel) {
    // TODO: implement updateComponent
  }



}