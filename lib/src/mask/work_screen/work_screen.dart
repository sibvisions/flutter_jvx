import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/panel/fl_panel_wrapper.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/command/layout/set_component_size_command.dart';

import '../../model/command/api/device_status_command.dart';

/// Screen used to show workScreens either custom or from the server,
/// will send a [DeviceStatusCommand] on open to account for
/// custom header/footer
class WorkScreen extends StatelessWidget with UiServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Title on top of the screen
  final String screenTitle;

  /// Widget used as workscreen
  final Widget screenWidget;

  /// 'True' if this a custom screen, a custom screen will not be registered
  final bool isCustomScreen;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  WorkScreen({required this.screenTitle, required this.screenWidget, required this.isCustomScreen, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    uiService.setRouteContext(pContext: context);

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(screenTitle),
        ),
        body: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          body: LayoutBuilder(builder: (context, constraints) {
            final viewInsets = EdgeInsets.fromWindowPadding(
                WidgetsBinding.instance!.window.viewInsets, WidgetsBinding.instance!.window.devicePixelRatio);

            if (!isCustomScreen) {
              _setScreenSize(pWidth: constraints.maxWidth, pHeight: constraints.maxHeight + viewInsets.bottom);
              _sendDeviceStatus(pWidth: constraints.maxWidth, pHeight: constraints.maxHeight + viewInsets.bottom);
            }

            log("viewInsets: ${viewInsets.bottom}");
            return SingleChildScrollView(
              child: Stack(
                children: [
                  SizedBox(
                    height: constraints.maxHeight + viewInsets.bottom,
                    width: constraints.maxWidth,
                  ),
                  screenWidget
                ],
              ),
            );
          }),
          //resizeToAvoidBottomInset: false,
        ),
        resizeToAvoidBottomInset: false,
      ),
    );

    // Used for debugging when selecting widgets via the debugger or debugging
    // pointer events - because the GestureDetector eats all events

    //   return Scaffold(
    //     appBar: AppBar(title: Text(screenModel.name)),
    //     body: Scaffold(
    //       body: LayoutBuilder(builder: (context, constraints) {
    //         return Stack(
    //           children: [screenWidget],
    //         );
    //       }),
    //       resizeToAvoidBottomInset: false,
    //     ),
    //     resizeToAvoidBottomInset: false,
    //   );
    // }
  }

  _setScreenSize({required double pWidth, required double pHeight}) {
    SetComponentSizeCommand command = SetComponentSizeCommand(
        componentId: (screenWidget as FlPanelWrapper).id, size: Size(pWidth, pHeight), reason: "Opened Work Screen");
    uiService.sendCommand(command);
  }

  _sendDeviceStatus({required double pWidth, required double pHeight}) {
    DeviceStatusCommand deviceStatusCommand =
        DeviceStatusCommand(screenWidth: pWidth, screenHeight: pHeight, reason: "Device was rotated");
    uiService.sendCommand(deviceStatusCommand);
  }
}
