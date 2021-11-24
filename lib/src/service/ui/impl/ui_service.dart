import 'dart:async';
import 'dart:ui';

import '../../../mixin/command_service_mixin.dart';
import '../../../model/command/api/login_command.dart';
import '../../../model/command/api/open_screen_command.dart';
import '../../../model/command/api/startup_command.dart';
import '../../../model/command/layout/preferred_size_command.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/menu/menu_model.dart';
import '../../../model/routing/route_to_menu.dart';
import '../../../model/routing/route_to_work_screen.dart';
import '../../../routing/app_delegate.dart';
import '../i_ui_service.dart';


/// Manages all interactions with the UI
// Author: Michael Schober
class UiService with CommandServiceMixin implements IUiService {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Used to send Routing events to [AppDelegate].
  final StreamController _routeStream = StreamController.broadcast();

  /// Last open menuModel
  MenuModel? menuModel;

  /// Last open Screen
  List<FlComponentModel> currentScreen = [];


  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


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
    return _routeStream.stream;
  }

  @override
  void routeToMenu(MenuModel menuModel) {
    this.menuModel = menuModel;
    RouteToMenu routeToMenu = RouteToMenu(menuModel: menuModel);
    _routeStream.sink.add(routeToMenu);
  }

  @override
  void routeToWorkScreen(List<FlComponentModel> screenComponents) {
    RouteToWorkScreen routeToWorkScreen = RouteToWorkScreen(screen: screenComponents.first);
    currentScreen = screenComponents;
    _routeStream.sink.add(routeToWorkScreen);
  }


  // Content
  @override
  List<FlComponentModel> getChildrenModels(String id) {
    var children = currentScreen.where((element) => element.parent == id).toList();
    return children;
  }

  @override
  MenuModel getCurrentMenu() {
    MenuModel? tempMenuModel = menuModel;
    if (tempMenuModel != null) {
      return tempMenuModel;
    } else {
      throw Exception("Menu was not found");
    }
  }

  @override
  void registerPreferredSize(String id, Size size) {
    PreferredSizeCommand preferredSizeCommand = PreferredSizeCommand(
        size: size,
        componentId: id,
        reason: "component has been rendered"
    );
    commandService.sendCommand(preferredSizeCommand);
  }



}