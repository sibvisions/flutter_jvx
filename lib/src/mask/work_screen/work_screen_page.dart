/*
 * Copyright 2023 SIB Visions GmbH
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

import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../../custom/custom_screen.dart';
import '../../exceptions/error_view_exception.dart';
import '../../flutter_ui.dart';
import '../../model/command/api/close_screen_command.dart';
import '../../model/command/api/navigation_command.dart';
import '../../model/command/api/open_screen_command.dart';
import '../../model/command/base_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/component/model_subscription.dart';
import '../../model/menu/menu_item_model.dart';
import '../../model/request/api_navigation_request.dart';
import '../../service/apps/i_app_service.dart';
import '../../service/command/i_command_service.dart';
import '../../service/config/i_config_service.dart';
import '../../service/layout/i_layout_service.dart';
import '../../service/storage/i_storage_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/image/image_loader.dart';
import '../frame/frame.dart';
import '../frame/open_drawer_action.dart';
import '../state/loading_bar.dart';
import 'error_screen.dart';
import 'skeleton_screen.dart';
import 'util/screen_wrapper.dart';
import 'util/simple_menu_action.dart';
import 'work_screen.dart';

/// Screen used to show JVx WorkScreens either custom or from the server.
///
/// Sends an [OpenScreenCommand] if necessary and handles model updates.
///
/// Sends a [DeviceStatusCommand] to account for custom header/footer.
class WorkScreenPage extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// ScreenName of an online-screen - used for sending [ApiNavigationRequest].
  final String screenName;

  const WorkScreenPage({
    super.key,
    required this.screenName,
  });

  /// Finds the [WorkScreenPageState] from the closest instance of this class that
  /// encloses the given context.
  static WorkScreenPageState of(BuildContext context) {
    final WorkScreenPageState? result = maybeOf(context);
    if (result != null) {
      return result;
    }
    throw FlutterError.fromParts([
      ErrorSummary(
        "WorkScreenPage.of() called with a context that does not contain a WorkScreenPage.",
      ),
      context.describeElement("The context used was"),
    ]);
  }

  /// Finds the [WorkScreenPageState] from the closest instance of this class that
  /// encloses the given context.
  ///
  /// If no instance of this class encloses the given context, will return null.
  /// To throw an exception instead, use [of] instead of this function.
  static WorkScreenPageState? maybeOf(BuildContext? context) {
    return context?.findAncestorStateOfType<WorkScreenPageState>();
  }

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
  WorkScreenPageState createState() => WorkScreenPageState();
}

class WorkScreenPageState extends State<WorkScreenPage> {
  /// Debounce re-layouts if keyboard opens.
  final BehaviorSubject<Size> subject = BehaviorSubject<Size>();
  FlPanelModel? model;

  /// Title displayed on the top
  String? screenTitle;

  /// Navigating booleans.
  bool isNavigating = false;
  bool isForced = false;

  bool sentScreen = false;

  MenuItemModel? item;
  Future<void>? future;

  CustomScreen? customScreen;

  @override
  void initState() {
    super.initState();

    IUiService().getAppManager()?.onScreenPage(widget.screenName);
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

      _init();
    }
  }

  void _setScreenSize(Size size) {
    ILayoutService()
        .setScreenSize(
          pScreenComponentId: model!.id,
          pSize: size,
        )
        .then((value) => value.forEach((e) async => await IUiService().sendCommand(e)));
  }

  void _init() {
    future = () async {
      // Send only if model is missing (which it always is in a custom screen) and the possible custom screen has send = true.
      if (model == null &&
          (customScreen == null || (customScreen!.sendOpenScreenRequests && !IConfigService().offline.value))) {
        await ICommandService().sendCommand(OpenScreenCommand(
          screenLongName: item!.screenLongName,
          reason: "Screen was opened",
        ));
      }
    }()
        .catchError((e, stack) {
      FlutterUI.log.e("Open screen failed", error: e, stackTrace: stack);
      if (e is ErrorViewException) {
        // Server failed to open this screen, beam back to old location.
        context.beamBack();
      }
      throw e;
    });
  }

  void rebuild() {
    IUiService().closeJVxDialogs();

    Navigator.of(FlutterUI.getCurrentContext()!).popUntil((route) => route is! PopupRoute);

    sentScreen = false;
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant WorkScreenPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    sentScreen = false;
  }

  @override
  Widget build(BuildContext context) {
    return Frame.wrapWithFrame(
      builder: (context, isOffline) {
        return FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            FrameState? frame = Frame.maybeOf(context);
            List<Widget>? actions = frame?.getActions();

            model = IStorageService().getComponentByScreenClassName(pScreenClassName: item!.screenLongName);
            bool noMenu = model?.noMenu ?? false;
            bool simpleMenu = model?.hasSimpleMenu ?? false;

            if (noMenu) {
              actions?.removeWhere((element) => element is OpenDrawerAction);

              if (simpleMenu) {
                actions?.add(const SimpleMenuAction());
              }
            }

            Widget? body;
            Widget? title;
            if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
              // Has to called first as it initializes [screenTitle].
              body = _buildWorkScreen(context, isOffline);

              title = Text(screenTitle!);
            }

            Widget? leading = _buildLeading();
            title ??=
                Text(customScreen?.screenTitle ?? item?.label ?? screenTitle ?? FlutterUI.translate("Loading..."));
            PreferredSizeWidget? appBar = frame?.getAppBar(
              leading: leading,
              titleSpacing: leading != null ? 0 : 8,
              title: title,
              actions: actions,
            );

            // Dummy body shown while loading/error.
            body ??= _buildDummyScreen(snapshot);

            // _onWillPop needs to access Scaffold.
            Widget content = Builder(
              builder: (context) => WillPopScope(
                onWillPop: () => _onWillPop(context),
                child: SafeArea(
                  child: body!,
                ),
              ),
            );

            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: appBar,
              drawerEnableOpenDragGesture: false,
              endDrawerEnableOpenDragGesture: false,
              drawer: noMenu ? null : frame?.getDrawer(context),
              endDrawer: noMenu ? null : frame?.getEndDrawer(context),
              body: frame?.wrapBody(content) ?? content,
            );
          },
        );
      },
    );
  }

  Widget _buildWorkScreen(BuildContext context, bool isOffline) {
    ScreenWrapper? builtScreen;

    if (model != null) {
      builtScreen = ScreenWrapper.jvx(model!);
    } else {
      builtScreen = ScreenWrapper.empty(screenTitle);
    }

    // Custom config for this screen
    CustomScreen? customScreen = IUiService().getCustomScreen(item!.screenLongName);
    if (customScreen != null) {
      builtScreen = ScreenWrapper.customScreen(context, customScreen, builtScreen);
    }

    // Update screenTitle
    screenTitle = builtScreen.screenTitle;

    return WorkScreen(
      isOffline: isOffline,
      item: item!,
      screen: builtScreen,
      updateSize: (size) {
        if (!sentScreen) {
          // Trigger update synchronously for layout.
          _setScreenSize(size);
          sentScreen = true;
        } else {
          subject.add(size);
        }
      },
    );
  }

  Widget _buildDummyScreen(AsyncSnapshot<void> snapshot) {
    Widget body;
    if (snapshot.connectionState == ConnectionState.none) {
      // Invalid screen name
      body = const ErrorScreen(
        message: "Screen not found.",
      );
    } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
      body = ErrorScreen(
        extra: snapshot.error?.toString(),
        retry: () {
          _init();
          setState(() {});
        },
      );
    } else {
      body = const SkeletonScreen();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: body,
    );
  }

  @override
  void dispose() {
    subject.close();
    IUiService().disposeSubscriptions(pSubscriber: this);
    super.dispose();
  }

  Widget? _buildLeading() {
    if (noBack || (overviewBack && !canGoToOverview)) {
      return null;
    }

    return InkResponse(
      radius: kToolbarHeight / 2,
      onTap: () => _onBack(),
      onDoubleTap: () => _onBack(true),
      child: Tooltip(
        message: MaterialLocalizations.of(context).backButtonTooltip,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Center(child: BackButtonIcon()),
        ),
      ),
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
    if (Scaffold.of(context).isDrawerOpen || Scaffold.of(context).isEndDrawerOpen) {
      return true;
    }

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

    if (!IUiService().usesNativeRouting(item!.screenLongName)) {
      return false;
    } else {
      if (noBack || overviewBack) {
        if (overviewBack && canGoToOverview) {
          unawaited(IUiService().routeToAppOverview());
        }
        return false;
      }
      return true;
    }
  }

  List<BaseCommand> _closeScreen() {
    List<BaseCommand> commands = [];
    if (!IUiService().usesNativeRouting(item!.screenLongName)) {
      if (isForced) {
        commands.add(
          CloseScreenCommand(
            reason: "Work screen back",
            screenName: model!.name,
          ),
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

  bool get noBack => model?.noBack == true;

  bool get overviewBack => model?.overviewBack == true;

  bool get canGoToOverview => !IConfigService().singleAppMode.value && IAppService().getAppIds().length > 1;
}
