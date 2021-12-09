import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter_client/src/model/command/base_command.dart';

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

  /// Last open Screen
  List<FlComponentModel> currentScreen = [];

  /// Live Component Registration
  HashMap<String, Function> registeredComponents = HashMap();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void sendCommand(BaseCommand command) {
    commandService.sendCommand(command);
  }

  // Routing
  @override
  Stream getRouteChangeStream() {
    return _routeStream.stream;
  }

  @override
  void routeToMenu(MenuModel menuModel) {
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
  void updateComponentModels(List<FlComponentModel> modelsToUpdate) {
    // Update All Models
    for (FlComponentModel newModel in modelsToUpdate) {
      FlComponentModel? toBeReplaced;
      for (FlComponentModel oldModel in currentScreen) {
        if (newModel.id == oldModel.id) {
          toBeReplaced = oldModel;
        }
      }

      // Replace Old with new Model or Add as new one.
      if (toBeReplaced != null) {
        toBeReplaced = newModel;
      } else {
        currentScreen.add(newModel);
      }
    }

    // Call callbacks of active components
    for (FlComponentModel newModel in modelsToUpdate) {
      Function? componentCallback = registeredComponents[newModel.id];
      if (componentCallback != null) {
        componentCallback.call(newModel);
      }
    }
  }

  @override
  void registerAsLiveComponent(String id, Function callback) {
    registeredComponents[id] = callback;
  }

}
