import 'dart:developer';

import 'package:beamer/beamer.dart';

import '../../components.dart';
import '../../custom/custom_screen.dart';
import '../../mixin/ui_service_mixin.dart';
import '../model/command/api/navigation_command.dart';
import 'locations/work_screen_location.dart';

class FlBackButtonDispatcher extends BeamerBackButtonDispatcher with UiServiceGetterMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlBackButtonDispatcher({required super.delegate});

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
      String workScreenName = delegate.configuration.location!.split("/")[2];

      // workScreenName can be the long name on custom screens, or a short one on replaced custom screens or VisionX screens
      FlPanelModel? model = getUiService().getComponentByName(pComponentName: workScreenName) as FlPanelModel?;

      String screenLongName = model?.screenLongName ?? workScreenName;

      if (getUiService().usesNativeRouting(pScreenLongName: screenLongName)) {
        CustomScreen screen = getUiService().getCustomScreen(pScreenLongName: screenLongName)!;
        bool isHandled = screen.onBack?.call() ?? false;
        return isHandled ? true : delegate.beamBack();
      } else {
        getUiService().sendCommand(NavigationCommand(reason: "Back button pressed", openScreen: workScreenName));
        return true;
      }
    } else {
      return delegate.beamBack();
    }
  }
}
