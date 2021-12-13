import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/layout/layout_position.dart';
import 'package:flutter_client/util/extensions/list_extensions.dart';
import 'package:flutter_client/util/type_def/callback_def.dart';

import '../../../mixin/command_service_mixin.dart';
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
  final List<FlComponentModel> _currentScreen = [];

  /// Live Component Registration
  final HashMap<String, ComponentCallback> _registeredComponents = HashMap();

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
    _currentScreen.addAll(screenComponents);
    _routeStream.sink.add(routeToWorkScreen);
  }

  // Content
  @override
  List<FlComponentModel> getChildrenModels(String id) {
    var children = _currentScreen.where((element) => element.parent == id).toList();
    return children;
  }

  // Active UI Management
  @override
  void registerAsLiveComponent({required String id, required ComponentCallback callback}) {
    _registeredComponents[id] = callback;
  }

  @override
  void deleteInactiveComponent({required Set<String> inactiveIds}) {
    for (String inactiveId in inactiveIds) {
      _currentScreen.removeWhere((screenComponent) => screenComponent.id == inactiveId);
      _registeredComponents.removeWhere((componentId, value) => componentId == inactiveId);
    }
  }

  @override
  void notifyAffectedComponents({required Set<String> affectedIds}) {
    for(String affectedId in affectedIds){
      ComponentCallback? callback = _registeredComponents[affectedId];
      if(callback != null){
        callback.call();
      }
    }
  }

  @override
  void notifyChangedComponents({required List<FlComponentModel> updatedModels}) {
    for(FlComponentModel updatedModel in updatedModels){
      // Change to new Model
      int indexOfOld = _currentScreen.indexWhere((element) => element.id == updatedModel.id);
      _currentScreen.removeAt(indexOfOld);
      _currentScreen.add(updatedModel);

      // Notify active component
      ComponentCallback? callback = _registeredComponents[updatedModel.id];
      if(callback != null){
        callback.call(newModel: updatedModel);
      } else {
        throw Exception("Component To Update not found");
      }
    }
  }

  @override
  void saveNewComponents({required List<FlComponentModel> newModels}) {
    newModels.addAll(newModels);
  }

  @override
  void setLayoutPosition({required String id, required LayoutPosition layoutPosition}) {
    ComponentCallback? callback = _registeredComponents[id];
    if(callback != null){
      callback.call(position: layoutPosition);
    } else {
      throw Exception("Component to set position not found");
    }
  }

}
