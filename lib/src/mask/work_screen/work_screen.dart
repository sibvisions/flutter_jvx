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

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../flutter_jvx.dart';
import '../../components/components_factory.dart';
import '../../components/panel/fl_panel_wrapper.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/component/model_subscription.dart';
import '../../model/menu/menu_item_model.dart';
import '../../util/offline_util.dart';
import '../frame/frame.dart';

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
  FlPanelModel? model;

  /// Title displayed on the top
  String screenTitle = "Loading...";

  /// Navigating booleans.
  bool isNavigating = false;
  bool isForced = false;

  bool sentScreen = false;

  MenuItemModel? item;
  Future<void>? future;

  CustomScreen? customScreen;

  String get screenLongName => item?.screenLongName ?? widget.screenName;

  @override
  void initState() {
    super.initState();
    subject.throttleTime(const Duration(milliseconds: 8), trailing: true).listen((size) => _setScreenSize(size));

    item = IUiService().getMenuItem(widget.screenName);
    if (item != null) {
      String className = IStorageService().convertLongScreenToClassName(item!.screenLongName);

      model = IStorageService().getComponentByScreenClassName(pScreenClassName: item!.screenLongName);
      customScreen = IUiService().getCustomScreen(item!.screenLongName);

      // Listen to new models with the same class names (needed for work screen reload, model id changes)
      IUiService().registerModelSubscription(ModelSubscription(
        subbedObj: this,
        check: (model) => model is FlPanelModel && model.screenClassName == className,
        onNewModel: (model) {
          if (model.id != this.model?.id) {
            this.model = model as FlPanelModel?;
            FlutterUI.logUI.d("Received new model for className: $className");
            rebuild();
          }
        },
      ));

      _initScreen();
    }
  }

  void _initScreen() {
    future = () async {
      // Send only if model is missing (which it always is in a custom screen) and the possible custom screen has send = true.
      if (model == null &&
          (customScreen == null || (customScreen!.sendOpenScreenRequests && !ConfigController().offline.value))) {
        await ICommandService()
            .sendCommand(OpenScreenCommand(
              screenLongName: item!.screenLongName,
              reason: "Screen was opened",
            ))
            .catchError(FlutterUI.createErrorHandler("Open screen failed"));
      }
    }();
  }

  @override
  void dispose() {
    subject.close();
    IUiService().disposeSubscriptions(pSubscriber: this);
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

  @override
  Widget build(BuildContext context) {
    return Frame.wrapWithFrame(
      forceWeb: IUiService().webOnly.value,
      forceMobile: IUiService().mobileOnly.value,
      builder: (context, isOffline) {
        return WillPopScope(
          onWillPop: () => _onWillPop(context),
          child: FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              FrameState? frame = Frame.maybeOf(context);
              List<Widget>? actions = frame?.getActions();

              if (!snapshot.hasError && snapshot.connectionState == ConnectionState.done) {
                Widget body = _buildBody(context, isOffline);
                return Scaffold(
                  resizeToAvoidBottomInset: false,
                  appBar: frame?.getAppBar(
                    leading: _buildLeading(),
                    title: Text(screenTitle),
                    actions: actions,
                  ),
                  drawerEnableOpenDragGesture: false,
                  endDrawerEnableOpenDragGesture: false,
                  drawer: frame?.getDrawer(context),
                  endDrawer: frame?.getEndDrawer(context),
                  body: frame?.wrapBody(body) ?? body,
                );
              } else {
                Widget body;
                if (snapshot.connectionState == ConnectionState.none) {
                  // Invalid screen name
                  body = Center(
                    child: Text(
                      FlutterUI.translate("Screen not found."),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  );
                } else if (snapshot.hasError) {
                  body = Center(
                    child: Text(
                      FlutterUI.translate("Error occurred while opening the screen."),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  );
                } else {
                  body = const Center(
                    child: SizedBox.square(
                      dimension: 150,
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // Skeleton scaffold shown while loading.
                return Scaffold(
                  resizeToAvoidBottomInset: false,
                  appBar: frame?.getAppBar(
                    leading: _buildLeading(),
                    title: Text(customScreen?.screenTitle ?? item?.label ?? FlutterUI.translate(screenTitle)),
                    actions: actions,
                  ),
                  drawerEnableOpenDragGesture: false,
                  endDrawerEnableOpenDragGesture: false,
                  drawer: frame?.getDrawer(context),
                  endDrawer: frame?.getEndDrawer(context),
                  body: frame?.wrapBody(body) ?? body,
                );
              }
            },
          ),
        );
      },
    );
  }

  InkWell _buildLeading() {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () {
        _onBack();
      },
      onDoubleTap: () {
        _onBack(true);
      },
      child: const Center(child: FaIcon(FontAwesomeIcons.arrowLeft)),
    );
  }

  Widget _wrapJVxScreen(
    BuildContext context,
    WrappedScreen wrappedScreen,
  ) {
    var appStyle = AppStyle.of(context).applicationStyle;
    Color? backgroundColor = ParseUtil.parseHexColor(appStyle['desktop.color']);
    String? backgroundImageString = appStyle['desktop.icon'];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      // If true, rebuilds and therefore can activate scrolling or not.
      appBar: wrappedScreen.header,
      bottomNavigationBar: wrappedScreen.footer,
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

            Widget screenWidget = wrappedScreen.screen!;
            if (!wrappedScreen.customScreen && screenWidget is FlPanelWrapper) {
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

  Widget _buildBody(BuildContext context, bool isOffline) {
    WrappedScreen? builtScreen;

    // Replace the model if a new one is found.
    // If there is no model, then just use the old one.
    // Happens when you close a screen but Flutter rebuilds it.
    FlPanelModel? newModel = item != null
        ? IStorageService().getComponentByScreenClassName(pScreenClassName: item!.screenLongName) //
        : null;
    model = newModel ?? model;

    if (model != null) {
      builtScreen = _buildScreen();
    }

    // Custom config for this screen
    CustomScreen? customScreen = IUiService().getCustomScreen(item!.screenLongName);
    if (customScreen != null) {
      builtScreen = _buildCustomScreen(context, customScreen, builtScreen);
    }

    // Update screenTitle
    screenTitle = builtScreen?.screenTitle ?? "No title";

    if (builtScreen?.screen == null) {
      FlutterUI.logUI.wtf("Model/Custom screen not found for work screen: $screenLongName");
      return Center(
        child: Text(
          FlutterUI.translate("Failed to load screen, please try again."),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
    }

    return FocusTraversalGroup(
      child: SafeArea(
        child: Column(
          children: [
            if (isOffline) OfflineUtil.getOfflineBar(context),
            Expanded(
              child: _wrapJVxScreen(
                context,
                builtScreen!,
              ),
            ),
          ],
        ),
      ),
    );
  }

  WrappedScreen? _buildScreen() {
    return WrappedScreen(
      screen: ComponentsFactory.buildWidget(model!),
      screenTitle: model!.screenTitle!,
    );
  }

  WrappedScreen _buildCustomScreen(
    BuildContext context,
    CustomScreen customScreen,
    WrappedScreen? screen,
  ) {
    Widget? replaceScreen = customScreen.screenBuilder?.call(context, screen?.screen);

    return WrappedScreen(
      header: customScreen.headerBuilder?.call(context),
      footer: customScreen.footerBuilder?.call(context),
      screen: replaceScreen ?? screen?.screen,
      screenTitle: customScreen.screenTitle ?? screen?.screenTitle ?? "Custom Screen",
      customScreen: replaceScreen != null,
    );
  }

  /// Is being called by Back button in [AppBar].
  Future<void> _onBack([bool pForced = false]) async {
    if (isNavigating) {
      return;
    }

    isForced = pForced;

    NavigatorState navigator = Navigator.of(context);
    if (!(await navigator.maybePop())) {
      if (!mounted) return;
      context.beamBack();
    }
  }

  /// Is being called by [WillPopScope].
  Future<bool> _onWillPop(BuildContext context) async {
    if (isNavigating || (LoadingBar.maybeOf(context)?.show ?? false)) {
      return false;
    }

    isNavigating = true;

    // We have no working screen, allow back.
    if (item?.screenLongName == null || (model == null && customScreen == null)) {
      return true;
    }

    await IUiService()
        .saveAllEditors(pReason: "Closing Screen", pFunction: _closeScreen)
        .catchError(IUiService().handleAsyncError)
        .whenComplete(() {
      isForced = false;
      isNavigating = false;
    });

    return IUiService().usesNativeRouting(item!.screenLongName);
  }

  Future<List<BaseCommand>> _closeScreen() async {
    List<BaseCommand> commands = [];
    if (!IUiService().usesNativeRouting(item!.screenLongName)) {
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
            openScreen: model!.name,
          ),
        );
      }
    }
    return commands;
  }

  void _setScreenSize(Size size) {
    ILayoutService()
        .setScreenSize(
          pScreenComponentId: model!.id,
          pSize: size,
        )
        .then((value) => value.forEach((e) async => await IUiService().sendCommand(e)));
  }
}

class WrappedScreen {
  /// Title displayed on the top
  final String screenTitle;

  /// Header
  final PreferredSizeWidget? header;

  /// Footer
  final Widget? footer;

  /// Screen Widget
  final Widget? screen;

  final bool customScreen;

  const WrappedScreen({
    required this.screenTitle,
    this.header,
    this.footer,
    this.screen,
    this.customScreen = false,
  });
}
