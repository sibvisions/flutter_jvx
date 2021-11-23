import 'dart:async';
import 'dart:developer';

import 'package:flutter_client/src/mixin/command_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/login_command.dart';
import 'package:flutter_client/src/model/command/api/open_screen_command.dart';
import 'package:flutter_client/src/model/command/api/startup_command.dart';
import 'package:flutter_client/src/model/component/fl_component_model.dart';
import 'package:flutter_client/src/model/menu/menu_model.dart';
import 'package:flutter_client/src/model/routing/route_to_menu.dart';
import 'package:flutter_client/src/model/routing/route_to_work_screen.dart';
import 'package:flutter_client/src/service/ui/i_ui_service.dart';

class UiService with CommandServiceMixin implements IUiService {

  StreamController routeStream = StreamController.broadcast();
  MenuModel? menuModel;
  List<FlComponentModel> currentScreen = [];


  // Api Commands
  @override
  void login(String userName, String password) {
    LoginCommand loginCommand = LoginCommand(userName: userName, password: password, reason: "User clicked on Login");
    commandService.sendCommand(loginCommand);
  }

  @override
  void startUp() {
    StartupCommand startupCommand = StartupCommand(reason: "App Started for 1st Time");
    commandService.sendCommand(startupCommand);
  }

  @override
  void openScreen(String componentId) {
    OpenScreenCommand openScreenCommand = OpenScreenCommand(
        componentId: componentId,
        reason: "UI component clicked menu item",
    );
    commandService.sendCommand(openScreenCommand);
  }

  // Routing
  @override
  Stream getRouteChangeStream() {
    return routeStream.stream;
  }

  @override
  void routeToMenu(MenuModel menuModel) {
    this.menuModel = menuModel;
    RouteToMenu routeToMenu = RouteToMenu(menuModel: menuModel);
    routeStream.sink.add(routeToMenu);
  }

  @override
  void routeToWorkScreen(List<FlComponentModel> screenComponents) {
    RouteToWorkScreen routeToWorkScreen = RouteToWorkScreen(screen: screenComponents.first);
    currentScreen = screenComponents;
    routeStream.sink.add(routeToWorkScreen);
  }


  // Structure
  @override
  List<FlComponentModel> getChildrenModels(String id) {
    var children = currentScreen.where((element) => element.parent == id).toList();
    return children;
  }

  @override
  MenuModel getCurrentMenu() {
    MenuModel? tempMenuModel = menuModel;
    if(tempMenuModel != null) {
      return tempMenuModel;
    } else {
      throw Exception("Menu was not found");
    }

  }



}