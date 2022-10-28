import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../services.dart';
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
import '../state/app_style.dart';

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
  WorkScreenState createState() => WorkScreenState();
}

class WorkScreenState extends State<WorkScreen> {
  /// Debounce re-layouts if keyboard opens.
  final BehaviorSubject<Size> subject = BehaviorSubject<Size>();

  @override
  void initState() {
    super.initState();

    subject.throttleTime(const Duration(milliseconds: 8), trailing: true).listen((size) => _setScreenSize(size));
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

    Widget body = SafeArea(
      child: Column(
        children: [
          if (IConfigService().isOffline()) OfflineUtil.getOfflineBar(context),
          Expanded(child: _getScreen(context)),
        ],
      ),
    );

    FrameState? frame = FrameState.of(context);
    if (frame != null) {
      actions.addAll(frame.getActions());
    }

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
                  child: const Center(child: FaIcon(FontAwesomeIcons.arrowLeft)),
                ),
                title: Text(widget.screenTitle),
                actions: actions,
                elevation: 0,
              ),
        drawerEnableOpenDragGesture: false,
        endDrawerEnableOpenDragGesture: false,
        drawer: frame?.getDrawer(context),
        endDrawer: frame?.getEndDrawer(context),
        body: frame?.wrapBody(body) ?? body,
      ),
    );
  }

  _setScreenSize(Size size) {
    ILayoutService()
        .setScreenSize(
          pScreenComponentId: (widget.screenWidget as FlPanelWrapper).id,
          pSize: size,
        )
        .then((value) => value.forEach((e) async => await IUiService().sendCommand(e)));
  }

  _onBackTap() {
    IUiService().saveAllEditorsThen(null, _navigateBack, "Back pressed");
  }

  _navigateBack() {
    if (IUiService().usesNativeRouting(pScreenLongName: widget.screenLongName)) {
      _customBack();
    } else {
      IUiService().sendCommand(NavigationCommand(reason: "Work screen back", openScreen: widget.screenName));
    }
  }

  _onDoubleTap() {
    IUiService().saveAllEditorsThen(null, _navigateBackForcefully, "Back pressed forcefully");
  }

  _navigateBackForcefully() {
    if (IUiService().usesNativeRouting(pScreenLongName: widget.screenLongName)) {
      _customBack();
    } else {
      IUiService().sendCommand(CloseScreenCommand(reason: "Work screen back", screenName: widget.screenName));
      IUiService().sendCommand(DeleteScreenCommand(reason: "Work screen back", screenName: widget.screenName));
    }
  }

  _customBack() async {
    bool handled = await Navigator.of(context).maybePop();
    if (!handled) {
      // ignore: use_build_context_synchronously
      context.beamBack();
    }
  }

  Widget _getScreen(BuildContext context) {
    var appStyle = AppStyle.of(context)!.applicationStyle!;
    Color? backgroundColor = ParseUtil.parseHexColor(appStyle['desktop.color']);
    String? backgroundImageString = appStyle['desktop.icon'];

    return Scaffold(
      resizeToAvoidBottomInset: true, // If true, rebuilds and therefore can activate scrolling or not.
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
          if (!widget.isCustomScreen && screenWidget is FlPanelWrapper) {
            Size size = Size(constraints.maxWidth, constraints.maxHeight + viewInsets.bottom);
            if (!sentScreen) {
              _setScreenSize(size);
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
            scrollDirection: Axis.vertical,
            child: Stack(
              children: [
                Container(
                  height: constraints.maxHeight + viewInsets.bottom,
                  width: constraints.maxWidth,
                  color: backgroundColor,
                  child: backgroundImageString != null
                      ? ImageLoader.loadImage(
                          backgroundImageString,
                          pFit: BoxFit.scaleDown,
                        )
                      : null,
                ),
                screenWidget
              ],
            ),
          );
        },
      ),
    );
  }
}
