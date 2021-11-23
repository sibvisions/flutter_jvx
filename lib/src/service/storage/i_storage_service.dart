import 'package:flutter_client/src/model/component/fl_component_model.dart';
import 'package:flutter_client/src/model/menu/menu_model.dart';

abstract class IStorageService {

  void saveMenu(MenuModel menuModel);
  MenuModel getMenu();

  void saveComponent(List<FlComponentModel> components);


  List<FlComponentModel> getScreenByScreenClassName(String screenClassName);

}