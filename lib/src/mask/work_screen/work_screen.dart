/* 
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../components/components_factory.dart';
import '../../components/panel/fl_panel_wrapper.dart';
import '../../custom/custom_screen.dart';
import '../../flutter_ui.dart';
import '../../model/command/api/close_screen_command.dart';
import '../../model/command/api/navigation_command.dart';
import '../../model/command/base_command.dart';
import '../../model/command/storage/delete_screen_command.dart';
import '../../model/command/ui/open_error_dialog_command.dart';
import '../../model/component/panel/fl_panel_model.dart';
import '../../service/config/config_service.dart';
import '../../service/layout/i_layout_service.dart';
import '../../service/storage/i_storage_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/image/image_loader.dart';
import '../../util/offline_util.dart';
import '../../util/parse_util.dart';
import '../frame/frame.dart';
import '../state/app_style.dart';
import '../state/loading_bar.dart';

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
    super.key,
    required this.screenName,
  });

  static Widget buildBackground(Color? backgroundColor, String? backgroundImage) {
    return SizedBox.expand(
      child: Container(
        color: backgroundColor,
        child: Center(
          child: backgroundImage != null
              ? ImageLoader.loadImage(
                  backgroundImage,
                  imageProvider: ImageLoader.getImageProvider(backgroundImage),
                  pFit: BoxFit.scaleDown,
                )
              : null,
        ),
      ),
    );
  }

  @override
  WorkScreenState createState() => WorkScreenState();
}

class WorkScreenState extends State<WorkScreen> {
  /// Debounce re-layouts if keyboard opens.
  final BehaviorSubject<Size> subject = BehaviorSubject<Size>();
  late FlPanelModel? model;
  late String screenLongName;

  /// Navigating booleans.
  bool isNavigating = false;
  bool isForced = false;

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
      forceWeb: ConfigService().isWebOnly(),
      forceMobile: ConfigService().isMobileOnly(),
      builder: (context, isOffline) {
        model = IStorageService().getComponentByName(pComponentName: widget.screenName) as FlPanelModel?;

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
          FlutterUI.logUI.wtf("Model not found for work screen: $screenLongName");
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

        Widget body = FocusTraversalGroup(
          child: SafeArea(
            child: Column(
              children: [
                if (isOffline) OfflineUtil.getOfflineBar(context),
                Expanded(
                  child: _getScreen(
                    context,
                    header,
                    screen,
                    footer,
                    isCustomScreen,
                  ),
                ),
              ],
            ),
          ),
        );

        FrameState? frame = FrameState.of(context);
        if (frame != null) {
          actions.addAll(frame.getActions());
        }

        return WillPopScope(
          onWillPop: () async {
            if (isNavigating || (LoadingBar.of(context)?.show ?? false)) {
              return false;
            }

            isNavigating = true;

            await IUiService()
                .saveAllEditors(pReason: "Closing Screen", pFunction: _willPopScope)
                .catchError(IUiService().handleAsyncError)
                .whenComplete(() {
              isForced = false;
              isNavigating = false;
            });

            return IUiService().usesNativeRouting(pScreenLongName: screenLongName);
          },
          child: Builder(builder: (context) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: frame?.getAppBar(
                leading: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    _back();
                  },
                  onDoubleTap: () {
                    _back(true);
                  },
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
            );
          }),
        );
      },
    );
  }

  Future<List<BaseCommand>> _willPopScope() async {
    List<BaseCommand> commands = [];
    if (!IUiService().usesNativeRouting(pScreenLongName: screenLongName)) {
      if (isForced) {
        commands.addAll(
          [
            CloseScreenCommand(
              reason: "Work screen back",
              screenName: widget.screenName,
            ),
            DeleteScreenCommand(
              reason: "Work screen back",
              screenName: widget.screenName,
            )
          ],
        );
      } else {
        commands.add(
          NavigationCommand(
            reason: "Back button pressed",
            openScreen: widget.screenName,
          ),
        );
      }
    }
    return commands;
  }

  Future<void> _back([bool pForced = false]) async {
    if (isNavigating) {
      return;
    }

    isForced = pForced;

    if (!(await Navigator.of(context).maybePop())) {
      context.beamBack();
    }
  }

  _setScreenSize(Size size) {
    ILayoutService()
        .setScreenSize(
          pScreenComponentId: model!.id,
          pSize: size,
        )
        .then((value) => value.forEach((e) async => await IUiService().sendCommand(e)));
  }

  Widget _getScreen(
    BuildContext context,
    PreferredSizeWidget? header,
    Widget screen,
    Widget? footer,
    bool isCustomScreen,
  ) {
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
                  SizedBox(
                    height: screenHeight,
                    width: constraints.maxWidth,
                    child: WorkScreen.buildBackground(backgroundColor, backgroundImageString),
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
