import 'dart:developer';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/navigation_command.dart';


class FlBackButtonDispatcher extends RootBackButtonDispatcher with UiServiceMixin  {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final BeamerDelegate delegate;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlBackButtonDispatcher({
    required this.delegate
  }) : super();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<bool> invokeCallback(Future<bool> defaultValue) async {

    log("backPressed");

    // Close popups
    bool couldPop = await super.invokeCallback(defaultValue);
    if(couldPop){
      return couldPop;
    }

    try{
      var a = uiService.getOpenScreen();
      NavigationCommand navigationCommand = NavigationCommand(
          reason: "Back button pressed"
      );
      uiService.sendCommand(navigationCommand);
      return true;
    } catch(e) {
      return delegate.beamBack();
    }
  }
}
