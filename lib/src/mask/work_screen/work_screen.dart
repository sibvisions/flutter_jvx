import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/panel/fl_panel_wrapper.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/api/requests/api_navigation_request.dart';
import 'package:flutter_client/src/model/command/api/close_screen_command.dart';
import 'package:flutter_client/src/model/command/layout/set_component_size_command.dart';
import 'package:flutter_client/src/model/command/storage/delete_screen_command.dart';
import 'package:flutter_client/util/misc/debouncer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../model/command/api/device_status_command.dart';
import '../../model/command/api/navigation_command.dart';
import '../drawer/drawer_menu.dart';

/// Screen used to show workScreens either custom or from the server,
/// will send a [DeviceStatusCommand] on open to account for
/// custom header/footer
class WorkScreen extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Title on top of the screen
  final String screenTitle;

  /// ScreenName of an online-screen - used for sending [ApiNavigationRequest]
  final String screenName;

  /// Widget used as workscreen
  final Widget screenWidget;

  /// 'True' if this a custom screen, a custom screen will not be registered
  final bool isCustomScreen;

  /// Header will be sticky displayed on top - header size will shrink space for screen
  final PreferredSizeWidget? header;

  /// Footer will be sticky displayed on top - footer size will shrink space for screen
  final Widget? footer;

  const WorkScreen({
    required this.screenTitle,
    required this.screenWidget,
    required this.isCustomScreen,
    required this.screenName,
    this.footer,
    this.header,
    Key? key,
  }) : super(key: key);

  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> with UiServiceMixin {
  /// Debounce re-layouts if keyboard opens.
  final Debounce debounce = Debounce(delay: const Duration(milliseconds: 500));

  @override
  Widget build(BuildContext context) {
    if (mounted) {
      uiService.setRouteContext(pContext: context);
    }

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: Center(
            child: GestureDetector(
              onTap: () => _onBackTab(context),
              onDoubleTap: () => _onDoubleTab(context),
              child: const CircleAvatar(
                backgroundColor: Colors.green,
                child: FaIcon(FontAwesomeIcons.arrowLeft),
              ),
            ),
          ),
          title: Text(widget.screenTitle),
        ),
        endDrawerEnableOpenDragGesture: false,
        endDrawer: DrawerMenu(),
        body: Scaffold(
          appBar: widget.header,
          bottomNavigationBar: widget.footer,
          backgroundColor: Theme.of(context).backgroundColor,
          body: LayoutBuilder(builder: (context, constraints) {
            final viewInsets = EdgeInsets.fromWindowPadding(
              WidgetsBinding.instance!.window.viewInsets,
              WidgetsBinding.instance!.window.devicePixelRatio,
            );

            if (!widget.isCustomScreen) {
              // debounce to not re-layout multiple times when opening the keyboard
              debounce.call(() {
                _setScreenSize(pWidth: constraints.maxWidth, pHeight: constraints.maxHeight + viewInsets.bottom);
                _sendDeviceStatus(pWidth: constraints.maxWidth, pHeight: constraints.maxHeight + viewInsets.bottom);
              });
            }
            return SingleChildScrollView(
              physics: viewInsets.bottom > 0 ? const ScrollPhysics() : const NeverScrollableScrollPhysics(),
              child: Stack(
                children: [
                  SizedBox(
                    height: constraints.maxHeight + viewInsets.bottom,
                    width: constraints.maxWidth,
                  ),
                  widget.screenWidget
                ],
              ),
            );
          }),
          //resizeToAvoidBottomInset: false,
        ),
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
      componentId: (widget.screenWidget as FlPanelWrapper).id,
      size: Size(pWidth, pHeight),
      reason: "Opened Work Screen",
    );
    uiService.sendCommand(command);
  }

  _sendDeviceStatus({required double pWidth, required double pHeight}) {
    DeviceStatusCommand deviceStatusCommand = DeviceStatusCommand(
      screenWidth: pWidth,
      screenHeight: pHeight,
      reason: "Device was rotated",
    );
    uiService.sendCommand(deviceStatusCommand);
  }

  _onBackTab(BuildContext context) {
    if (widget.isCustomScreen) {
      context.beamToNamed("/menu");
    } else {
      uiService.sendCommand(NavigationCommand(reason: "Work screen back", openScreen: widget.screenName));
    }
  }

  _onDoubleTab(BuildContext context) {
    if (widget.isCustomScreen) {
      context.beamToNamed("/menu");
    } else {
      uiService.sendCommand(CloseScreenCommand(reason: "Work screen back", screenName: widget.screenName));
      uiService.sendCommand(DeleteScreenCommand(reason: "Work screen back", screenName: widget.screenName));
    }
  }
}
