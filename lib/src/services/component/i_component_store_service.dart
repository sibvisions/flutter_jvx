import 'package:flutter_jvx/src/models/api/component/ui_component_model.dart';

abstract class IComponentStoreService{


  ///Returns true if [componentModel] was added, false if it already exits
  ///
  ///Only saves [componentModel] if it does not exist already,
  ///the component will be identified by it's id.
  bool saveComponent(UiComponentModel componentModel);

  ///Returns true if an existing [componentModel] was updated, false if no component to update was found
  ///
  ///Only overwrites fields which are present in the provided [componentModel].
  bool  updateComponent(UiComponentModel componentModel);


  void removeComponentById(String id);
  void deleteComponentById(String id);
  void activateComponentById(String id);

  List<UiComponentModel> getChildrenById(String id);
  UiComponentModel? getComponentById(String id);
  UiComponentModel? getScreenByScreenClassName(String screenClassName);
  bool doesComponentExistById(String id);
  bool isComponentRemovedById(String id);


  List<UiComponentModel> getAll();
}