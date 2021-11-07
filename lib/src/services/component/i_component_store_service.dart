import 'package:flutter_jvx/src/models/api/component/ui_component_model.dart';

abstract class IComponentStoreService{


  void saveComponent(UiComponentModel componentModel);
  void updateComponent(UiComponentModel componentModel);
  void removeComponentById(String id);
  void deleteComponentById(String id);
  void activateRemovedComponentById(String id);

  List<UiComponentModel> getChildrenById(String id);
  UiComponentModel? getComponentById(String id);
  UiComponentModel? getScreenByScreenClassName(String screenClassName);
  bool doesComponentExistById(String id);
  bool isComponentRemovedById(String id);
}