import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/layout/layout_position.dart';
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

  /// Sends [command] to [ICommandService]
  void sendCommand(BaseCommand command);

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

  /// Updates Components Models, also tells affected Parents to re-build their children
  void updateComponentModels({List<FlComponentModel>? modelsToUpdate, List<LayoutPosition>? layoutPositions});

  /// Register as an active Component, callback will be called when model changes or children should be rebuilt.
  void registerAsLiveComponent(String id, Function callback);
}
