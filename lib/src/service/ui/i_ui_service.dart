import 'dart:async';

import 'package:flutter_client/src/model/component/fl_component_model.dart';
import 'package:flutter_client/src/model/menu/menu_model.dart';

abstract class IUiService {

  // ApiCalls
  void startUp();
  void login(String userName, String password);
  void openScreen(String componentId);


  // Routing
  void routeToMenu(MenuModel menuModel);
  void routeToWorkScreen(List<FlComponentModel> screenComponents);
  Stream getRouteChangeStream();


  // Structure
  List<FlComponentModel> getChildrenModels(String id);
  MenuModel getCurrentMenu();
}
