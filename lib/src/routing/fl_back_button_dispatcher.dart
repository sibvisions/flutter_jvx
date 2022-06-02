import 'dart:developer';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/navigation_command.dart';
import 'package:flutter_client/src/model/custom/custom_screen.dart';
import 'package:flutter_client/src/routing/locations/work_sceen_location.dart';

class FlBackButtonDispatcher extends RootBackButtonDispatcher with UiServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final BeamerDelegate delegate;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlBackButtonDispatcher({required this.delegate}) : super();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~C
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<bool> invokeCallback(Future<bool> defaultValue) async {
    log("backPressed");

    // Close popups
    bool couldPop = await super.invokeCallback(defaultValue);
    if (couldPop) {
      return couldPop;
    }

    if (delegate.beamingHistory.last.runtimeType == WorkScreenLocation) {
      String location = delegate.configuration.location!.split("/")[2];
      CustomScreen? screen = uiService.getCustomScreen(pScreenName: location);

      if (screen != null && screen.isOfflineScreen) {
        return delegate.beamBack();
      } else {
        uiService.sendCommand(NavigationCommand(reason: "Back button pressed", openScreen: location));
        return true;
      }
    } else {
      return delegate.beamBack();
    }
  }
}
