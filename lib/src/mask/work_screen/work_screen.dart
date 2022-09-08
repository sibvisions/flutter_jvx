import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../main.dart';
import '../../../mixin/config_service_mixin.dart';
import '../../../mixin/layout_service_mixin.dart';
import '../../../mixin/ui_service_mixin.dart';
import '../../../util/image/image_loader.dart';
import '../../../util/parse_util.dart';
import '../../components/panel/fl_panel_wrapper.dart';
import '../../model/command/api/close_screen_command.dart';
import '../../model/command/api/device_status_command.dart';
import '../../model/command/api/navigation_command.dart';
import '../../model/command/storage/delete_screen_command.dart';
import '../../model/request/api_navigation_request.dart';
import '../../util/offline_util.dart';
import '../frame/frame.dart';
import '../frame/web_frame.dart';

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

class _WorkScreenState extends State<WorkScreen>
    with ConfigServiceGetterMixin, UiServiceGetterMixin, LayoutServiceGetterMixin {
  /// Debounce re-layouts if keyboard opens.
  final BehaviorSubject<Size> subject = BehaviorSubject<Size>();

  FocusNode? currentObjectFocused;

  @override
  void initState() {
    super.initState();

    subject.throttleTime(const Duration(milliseconds: 8)).listen((size) {
      _setScreenSize(size);
      _sendDeviceStatus(pWidth: size.width, pHeight: size.height);
    });
  }

  @override
  void dispose() {
    subject.close();
    super.dispose();
  }

  bool sentScreen = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [];

    Widget body = Column(
      children: [
        if (getConfigService().isOffline()) OfflineUtil.getOfflineBar(context),
        Expanded(child: _getScreen(context)),
      ],
    );

    FrameState frame = Frame.of(context)!;

    actions.addAll(frame.getActions());

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: frame is WebFrameState
            ? frame.getAppBar(actions)
            : AppBar(
                leading: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _onBackTap(),
                  onDoubleTap: () => _onDoubleTap(),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.arrowLeft,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                title: Text(widget.screenTitle),
                actions: actions,
              ),
        endDrawerEnableOpenDragGesture: false,
        endDrawer: frame.getEndDrawer(),
        body: frame.wrapBody(body),
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

  _setScreenSize(Size size) {
    getLayoutService().setScreenSize(
      pScreenComponentId: (widget.screenWidget as FlPanelWrapper).id,
      pSize: size,
    );
  }

  _sendDeviceStatus({required double pWidth, required double pHeight}) {
    if (!getConfigService().isOffline()) {
      DeviceStatusCommand deviceStatusCommand = DeviceStatusCommand(
        screenWidth: pWidth,
        screenHeight: pHeight,
        reason: "Device was rotated",
      );
      getUiService().sendCommand(deviceStatusCommand);
    }
  }

  _onBackTap() {
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

  _customBack() async {
    bool handled = await Navigator.of(context).maybePop();
    if (!handled) {
      context.beamBack();
    }
  }

  Widget _getScreen(BuildContext context) {
    Color? backgroundColor = ParseUtil.parseHexColor(getConfigService().getAppStyle()?['desktop.color']);
    String? backgroundImageString = getConfigService().getAppStyle()?['desktop.icon'];

    return Scaffold(
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
            Size size = Size(constraints.maxWidth, constraints.maxHeight + viewInsets.bottom);
            if (!sentScreen) {
              _setScreenSize(size);
              _sendDeviceStatus(pWidth: size.width, pHeight: size.height);
              sentScreen = true;
            } else {
              subject.add(size);
            }
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
                  color: backgroundColor,
                  child: backgroundImageString != null
                      ? ImageLoader.loadImage(
                          backgroundImageString,
                          fit: BoxFit.scaleDown,
                        )
                      : null,
                ),
                screenWidget
              ],
            ),
          );
        },
      ),
      //resizeToAvoidBottomInset: false,
    );
  }
}
