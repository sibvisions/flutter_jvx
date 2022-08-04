import 'dart:developer';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import '../../custom/custom_screen.dart';
import '../../mixin/ui_service_mixin.dart';
import '../model/command/api/navigation_command.dart';
import 'locations/work_screen_location.dart';

class FlBackButtonDispatcher extends RootBackButtonDispatcher with UiServiceGetterMixin {
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
      CustomScreen? screen = getUiService().getCustomScreen(pScreenName: location);

      if (screen != null && !getUiService().hasReplaced(pScreenLongName: screen.screenLongName)) {
        return delegate.beamBack();
      } else {
        getUiService().sendCommand(NavigationCommand(reason: "Back button pressed", openScreen: location));
        return true;
      }
    } else {
      return delegate.beamBack();
    }
  }
}
