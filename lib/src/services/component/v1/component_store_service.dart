import 'package:flutter_jvx/src/models/api/component/panel/ui_panel_model.dart';
import 'package:flutter_jvx/src/models/api/component/ui_component_model.dart';
import 'package:flutter_jvx/src/services/component/i_component_store_service.dart';

class ComponentStoreService implements IComponentStoreService {


  final List<UiComponentModel> components = [];
  final List<UiComponentModel> removedComponents = [];

  @override
  bool saveComponent(UiComponentModel componentModel) {
    if(!components.any((element) => element.id == componentModel.id)){
      components.add(componentModel);
    }

    return true;
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

    //List.firstWhere throws Exception if none are found, this does not :|
    int indexOfScreen = components.indexWhere((element) =>
        _compareScreenClassName(element, screenClassName));
    if(indexOfScreen != -1){
      return components[indexOfScreen];
    }
    return null;
  }

  bool _compareScreenClassName(UiComponentModel model, String screenClassName){
    UiPanelModel panelModel = model as UiPanelModel;
    if(panelModel.screenClassName == screenClassName){
      return true;
    }
    return false;
  }

  @override
  void activateComponentById(String id) {
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
  bool updateComponent(UiComponentModel componentModel) {


    return true;
  }

  @override
  List<UiComponentModel> getAll() {
    return components;
  }



}