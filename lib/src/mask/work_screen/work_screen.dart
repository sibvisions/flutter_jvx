import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../components.dart';
import '../../../custom/custom_screen.dart';
import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../../../util/image/image_loader.dart';
import '../../../util/parse_util.dart';
import '../../components/components_factory.dart';
import '../../components/panel/fl_panel_wrapper.dart';
import '../../model/command/api/close_screen_command.dart';
import '../../model/command/api/device_status_command.dart';
import '../../model/command/api/navigation_command.dart';
import '../../model/command/storage/delete_screen_command.dart';
import '../../model/command/ui/open_error_dialog_command.dart';
import '../../model/request/api_navigation_request.dart';
import '../../util/offline_util.dart';
import '../frame/frame.dart';
import '../state/app_style.dart';

/// Screen used to show workScreens either custom or from the server,
/// will send a [DeviceStatusCommand] on open to account for
/// custom header/footer
class WorkScreen extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// ScreenName of an online-screen - used for sending [ApiNavigationRequest]
  final String screenName;

  const WorkScreen({
    required this.screenName,
    Key? key,
  }) : super(key: key);

  @override
  WorkScreenState createState() => WorkScreenState();
}

class WorkScreenState extends State<WorkScreen> {
  /// Debounce re-layouts if keyboard opens.
  final BehaviorSubject<Size> subject = BehaviorSubject<Size>();
  late FlPanelModel? model;
  late String screenLongName;

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

  @override
  void didUpdateWidget(covariant WorkScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    sentScreen = false;
  }

  void rebuild() {
    sentScreen = false;
    setState(() {});
  }

  bool sentScreen = false;

  @override
  Widget build(BuildContext context) {
    return Frame.wrapWithFrame(
        forceWeb: IConfigService().isWebOnly(),
        forceMobile: IConfigService().isMobileOnly(),
        builder: (context, isOffline) {
          model = IUiService().getComponentByName(pComponentName: widget.screenName) as FlPanelModel?;

          // Header
          PreferredSizeWidget? header;
          // Footer
          Widget? footer;
          // Title displayed on the top
          String screenTitle = "No Title";
          // Screen Widget
          Widget? screen;

          bool isCustomScreen = false;

          if (model != null) {
            screen = ComponentsFactory.buildWidget(model!);
            screenTitle = model!.screenTitle!;
          }

          screenLongName = model?.screenLongName ?? widget.screenName;

          // Custom Config for this screen
          CustomScreen? customScreen = IUiService().getCustomScreen(pScreenLongName: screenLongName);

          if (customScreen != null) {
            header = customScreen.headerBuilder?.call(context);
            footer = customScreen.footerBuilder?.call(context);

            Widget? replaceScreen = customScreen.screenBuilder?.call(context, screen);
            if (replaceScreen != null) {
              isCustomScreen = true;
              screen = replaceScreen;
            }

            String? customTitle = customScreen.screenTitle;
            if (customTitle != null) {
              screenTitle = customTitle;
            } else if (customScreen.menuItemModel != null) {
              screenTitle = customScreen.menuItemModel!.label;
            }
          }

          if (screen == null) {
            FlutterJVx.logUI.wtf("Model not found for work screen: $screenLongName");
            screen = Container();
            SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
              IUiService().sendCommand(OpenErrorDialogCommand(
                message: "Failed to open screen, please try again.",
                reason: "Workscreen Model missing",
              ));
              IUiService().routeToMenu(pReplaceRoute: true);
            });
          }

          List<Widget> actions = [];

          Widget body = SafeArea(
            child: Column(
              children: [
                if (isOffline) OfflineUtil.getOfflineBar(context),
                Expanded(child: _getScreen(context, header, screen, footer, isCustomScreen)),
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
            child: WillPopScope(
              onWillPop: () async {
                if (!IUiService().usesNativeRouting(pScreenLongName: screenLongName)) {
                  unawaited(IUiService()
                      .sendCommand(NavigationCommand(reason: "Back button pressed", openScreen: widget.screenName)));
                  return false;
                }
                return true;
              },
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: frame?.getAppBar(
                  leading: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _onBackTap(),
                    onDoubleTap: () => _onDoubleTap(),
                    child: const Center(child: FaIcon(FontAwesomeIcons.arrowLeft)),
                  ),
                  title: Text(screenTitle),
                  actions: actions,
                ),
                drawerEnableOpenDragGesture: false,
                endDrawerEnableOpenDragGesture: false,
                drawer: frame?.getDrawer(context),
                endDrawer: frame?.getEndDrawer(context),
                body: frame?.wrapBody(body) ?? body,
              ),
            ),
          );
        });
  }

  _setScreenSize(Size size) {
    ILayoutService()
        .setScreenSize(
          pScreenComponentId: model!.id,
          pSize: size,
        )
        .then((value) => value.forEach((e) async => await IUiService().sendCommand(e)));
  }

  _onBackTap() {
    IUiService().saveAllEditorsThen(null, _navigateBack, "Back pressed");
  }

  _navigateBack() {
    if (IUiService().usesNativeRouting(pScreenLongName: screenLongName)) {
      _customBack();
    } else {
      IUiService().sendCommand(NavigationCommand(reason: "Work screen back", openScreen: widget.screenName));
    }
  }

  _onDoubleTap() {
    IUiService().saveAllEditorsThen(null, _navigateBackForcefully, "Back pressed forcefully");
  }

  _navigateBackForcefully() {
    if (IUiService().usesNativeRouting(pScreenLongName: screenLongName)) {
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

  Widget _getScreen(
      BuildContext context, PreferredSizeWidget? header, Widget screen, Widget? footer, bool isCustomScreen) {
    var appStyle = AppStyle.of(context)!.applicationStyle!;
    Color? backgroundColor = ParseUtil.parseHexColor(appStyle['desktop.color']);
    String? backgroundImageString = appStyle['desktop.icon'];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      // If true, rebuilds and therefore can activate scrolling or not.
      appBar: header,
      bottomNavigationBar: footer,
      backgroundColor: Colors.transparent,
      body: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) => LayoutBuilder(
          builder: (context, constraints) {
            final viewInsets = EdgeInsets.fromWindowPadding(
              WidgetsBinding.instance.window.viewInsets,
              WidgetsBinding.instance.window.devicePixelRatio,
            );

            final viewPadding = EdgeInsets.fromWindowPadding(
              WidgetsBinding.instance.window.viewPadding,
              WidgetsBinding.instance.window.devicePixelRatio,
            );

            double screenHeight = constraints.maxHeight;

            if (isKeyboardVisible) {
              screenHeight += viewInsets.bottom;
              screenHeight -= viewPadding.bottom;
            }

            Widget screenWidget = screen;
            if (!isCustomScreen && screenWidget is FlPanelWrapper) {
              Size size = Size(constraints.maxWidth, screenHeight);
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
              physics: isKeyboardVisible ? const ScrollPhysics() : const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Stack(
                children: [
                  Container(
                    height: screenHeight,
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
      ),
    );
  }
}
