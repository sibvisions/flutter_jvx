import 'dart:developer';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../custom/custom_screen.dart';
import '../../../mixin/config_service_mixin.dart';
import '../../../mixin/ui_service_mixin.dart';
import '../../../util/image/image_loader.dart';
import '../../../util/parse_util.dart';
import '../../components/panel/fl_panel_wrapper.dart';
import '../../model/command/api/close_screen_command.dart';
import '../../model/command/api/device_status_command.dart';
import '../../model/command/api/navigation_command.dart';
import '../../model/command/layout/set_component_size_command.dart';
import '../../model/command/storage/delete_screen_command.dart';
import '../../model/request/api_navigation_request.dart';
import '../../util/misc/debouncer.dart';
import '../../util/offline_util.dart';
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

  /// Screen long name of an screen
  final String screenLongName;

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
    required this.screenLongName,
    this.footer,
    this.header,
    Key? key,
  }) : super(key: key);

  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> with UiServiceGetterMixin, ConfigServiceGetterMixin {
  /// Debounce re-layouts if keyboard opens.
  final Debounce debounce = Debounce(delay: const Duration(milliseconds: 500));

  FocusNode? currentObjectFocused;

  @override
  Widget build(BuildContext context) {
    if (mounted) {
      getUiService().setRouteContext(pContext: context);
    }
    Color? backgroundColor = ParseUtil.parseHexColor(getConfigService().getAppStyle()?['desktop.color']);
    String? backgroundImageString = getConfigService().getAppStyle()?['desktop.icon'];

    log("WORKSCREEN Layoutbuilder build: " + MediaQuery.of(context).viewInsets.bottom.toString());

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: Center(
            child: InkWell(
              onTap: () => _onBackTap(),
              onDoubleTap: () => _onDoubleTap(),
              child: CircleAvatar(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                backgroundColor: Theme.of(context).primaryColor,
                child: const FaIcon(FontAwesomeIcons.arrowLeft),
              ),
            ),
          ),
          title: Text(widget.screenTitle),
          actions: [
            Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                icon: const FaIcon(FontAwesomeIcons.ellipsisVertical),
              ),
            ),
          ],
        ),
        endDrawerEnableOpenDragGesture: false,
        endDrawer: const DrawerMenu(),
        body: Column(
          children: [
            if (getConfigService().isOffline()) OfflineUtil.getOfflineBar(context),
            Expanded(
              child: Scaffold(
                appBar: widget.header,
                bottomNavigationBar: widget.footer,
                backgroundColor: Colors.transparent,
                body: LayoutBuilder(
                  builder: (context, constraints) {
                    final viewInsets = EdgeInsets.fromWindowPadding(
                      WidgetsBinding.instance.window.viewInsets,
                      WidgetsBinding.instance.window.devicePixelRatio,
                    );
                    Widget screenWidget = widget.screenWidget;
                    if (!widget.isCustomScreen) {
                      // debounce to not re-layout multiple times when opening the keyboard
                      _setScreenSize(pWidth: constraints.maxWidth, pHeight: constraints.maxHeight + viewInsets.bottom);
                      _sendDeviceStatus(
                          pWidth: constraints.maxWidth, pHeight: constraints.maxHeight + viewInsets.bottom);
                    } else {
                      // Wrap custom screen in Positioned
                      screenWidget = Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: screenWidget,
                      );
                    }
                    return SingleChildScrollView(
                      physics: viewInsets.bottom > 0 ? const ScrollPhysics() : const NeverScrollableScrollPhysics(),
                      child: Stack(
                        children: [
                          Container(
                            height: constraints.maxHeight + viewInsets.bottom,
                            width: constraints.maxWidth,
                            child: backgroundImageString != null
                                ? ImageLoader.loadImage(
                                    backgroundImageString,
                                    fit: BoxFit.scaleDown,
                                  )
                                : null,
                            color: backgroundColor,
                          ),
                          screenWidget
                        ],
                      ),
                    );
                  },
                ),
                //resizeToAvoidBottomInset: false,
              ),
            ),
          ],
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
    getUiService().sendCommand(command);
  }

  _sendDeviceStatus({required double pWidth, required double pHeight}) {
    DeviceStatusCommand deviceStatusCommand = DeviceStatusCommand(
      screenWidth: pWidth,
      screenHeight: pHeight,
      reason: "Device was rotated",
    );
    getUiService().sendCommand(deviceStatusCommand);
  }

  _onBackTap() {
    getUiService().setRouteContext(pContext: context);

    currentObjectFocused = FocusManager.instance.primaryFocus;
    if (currentObjectFocused == null || currentObjectFocused!.parent == null) {
      _navigateBack();
    } else {
      currentObjectFocused!.addListener(_navigateBack);
      currentObjectFocused!.unfocus();
    }
  }

  _navigateBack() {
    if (currentObjectFocused != null) {
      currentObjectFocused!.removeListener(_navigateBack);
      currentObjectFocused = null;
    }

    if (getUiService().usesNativeRouting(pScreenLongName: widget.screenLongName)) {
      _customBack();
    } else {
      getUiService().sendCommand(NavigationCommand(reason: "Work screen back", openScreen: widget.screenName));
    }
  }

  _onDoubleTap() {
    getUiService().setRouteContext(pContext: context);

    currentObjectFocused = FocusManager.instance.primaryFocus;
    if (currentObjectFocused == null || currentObjectFocused!.parent == null) {
      _navigateBackForcefully();
    } else {
      currentObjectFocused!.addListener(_navigateBackForcefully);
      currentObjectFocused!.unfocus();
    }
  }

  _navigateBackForcefully() {
    if (currentObjectFocused != null) {
      currentObjectFocused!.removeListener(_navigateBackForcefully);
      currentObjectFocused = null;
    }

    if (getUiService().usesNativeRouting(pScreenLongName: widget.screenLongName)) {
      _customBack();
    } else {
      getUiService().sendCommand(CloseScreenCommand(reason: "Work screen back", screenName: widget.screenName));
      getUiService().sendCommand(DeleteScreenCommand(reason: "Work screen back", screenName: widget.screenName));
    }
  }

  _customBack() {
    CustomScreen? screen = getUiService().getCustomScreen(pScreenLongName: widget.screenLongName);
    bool isHandled = screen?.onBack?.call() ?? false;
    if (!isHandled) context.beamToNamed("/menu");
  }
}
