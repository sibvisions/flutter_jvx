import 'dart:async';

import 'package:flutter/material.dart';
import '../../model/command/api/login_command.dart';
import '../../model/command/api/open_screen_command.dart';
import '../../model/command/api/startup_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/menu/menu_model.dart';
import '../../model/routing/route_to_menu.dart';
import '../../model/routing/route_to_work_screen.dart';
import '../command/i_command_service.dart';

/// Defines the base construct of a [IUiService]
/// Used to manage all interactions to and from the ui.
// Author: Michael Schober
abstract class IUiService {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Sends [StartupCommand] to [ICommandService].
  void startUp();

  /// Sends [LoginCommand] to [ICommandService].
  void login(String userName, String password);

  /// Sends [OpenScreenCommand] to [ICommandService].
  void openScreen(String componentId);

  /// Sends out [RouteToMenu] event on routeChangeStream,
  /// provided [menuModel] will be displayed and saved.
  void routeToMenu(MenuModel menuModel);

  /// Sends out [RouteToWorkScreen] event on routeChangeStream.
  /// provided [FlComponentModel]s will be displayed and saved.
  void routeToWorkScreen(List<FlComponentModel> screenComponents);

  /// Returns broadcast [Stream] on which routing events will take place.
  Stream getRouteChangeStream();

  /// Returns all [FlComponentModel] children of provided id.
  List<FlComponentModel> getChildrenModels(String id);

  /// Returns current menu, will throw exception if none found.
  MenuModel getCurrentMenu();

  /// Register a Components preferred Size
  /// Will send [soon] Command.
  void registerPreferredSize(String id, Size size);
}
