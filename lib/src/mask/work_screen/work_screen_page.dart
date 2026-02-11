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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rxdart/rxdart.dart';

import '../../custom/custom_screen.dart';
import '../../flutter_ui.dart';
import '../../model/command/api/activate_screen_command.dart';
import '../../model/command/api/close_screen_command.dart';
import '../../model/command/api/navigation_command.dart';
import '../../model/command/api/open_screen_command.dart';
import '../../model/command/base_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/component/model_subscription.dart';
import '../../model/menu/menu_item_model.dart';
import '../../model/request/api_navigation_request.dart';
import '../../service/command/i_command_service.dart';
import '../../service/config/i_config_service.dart';
import '../../service/layout/i_layout_service.dart';
import '../../service/storage/i_storage_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/image/image_loader.dart';
import '../../util/jvx_logger.dart';
import '../../util/offline_util.dart';
import '../../util/parse_util.dart';
import '../frame/frame.dart';
import '../frame/open_drawer_action.dart';
import '../state/app_style.dart';
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
                  fit: BoxFit.scaleDown,
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
  late final StreamSubscription<Size> subscription;

  FlPanelModel? model;

  /// The color of the safe area
  Color? safeAreaColor;

  MenuItemModel? item;
  Future<bool>? future;

  CustomScreen? customScreen;

  /// Title displayed on the top
  String? screenTitle;

  /// Navigating booleans.
  bool isNavigating = false;
  bool isForced = false;

  bool sentScreenSizeForLayout = false;

  bool _useOwnNavigation = true;

  @override
  void initState() {
    super.initState();

    IUiService servUi = IUiService();

    _useOwnNavigation = !IConfigService().offline.value || (customScreen != null && customScreen!.sendOpenScreenRequests);

    servUi.getAppManager()?.onScreenPage(widget.screenName);
    subscription =
        subject.throttleTime(const Duration(milliseconds: 16), leading: false, trailing: true).listen(_setScreenSize);

    item = servUi.getMenuItem(widget.screenName);
    if (item != null) {
      IStorageService servStorage = IStorageService();

      model = servStorage.getComponentByScreenClassName(pScreenClassName: item!.screenLongName);

      customScreen = servUi.getCustomScreen(item!.screenLongName);

      String className = model?.screenClassName ?? servStorage.convertLongScreenToClassName(item!.screenLongName);

      // Listen to new models with the same class names (needed for work screen reload, model id changes)
      servUi.registerModelSubscription(ModelSubscription(
        subbedObj: this,
        check: (newModel) => newModel is FlPanelModel && newModel.screenClassName == className,
        onNewModel: (newModel) {
          if (newModel.id != model?.id) {
            model = newModel as FlPanelModel;

            if (FlutterUI.logUI.cl(Lvl.d)) {
              FlutterUI.logUI.d("Received new model for className: $className");
            }

            rebuild();
          }
        },
      ));

      _init();

    } else {
      future = Future.error("No menu item model found for this workscreen!");

      // _onBack() needs a usable context.
      // Wait for popup menu close, mitigates navigator update bug:
      // https://github.com/flutter/flutter/issues/82437
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 350)).then((_) => _onBack());
      });
    }
  }

  @override
  void didUpdateWidget(covariant WorkScreenPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    sentScreenSizeForLayout = false;
  }

  @override
  void dispose() {
    WorkScreen.remove(model?.name);

    subscription.cancel();
    subject.close();

    IUiService servUi = IUiService();

    servUi.disposeSubscriptions(this);

    super.dispose();
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

            if (snapshot.connectionState == ConnectionState.done && snapshot.data == true) {
              // Has to called first as it initializes [screenTitle].
              body = _buildWorkScreen(context, isOffline);

              title = Text(screenTitle!);
            }

            Widget? leading = _buildLeading();

            String? customScreenTitle = customScreen?.screenTitle;

            if (customScreenTitle != null) {
              customScreenTitle = FlutterUI.translate(customScreenTitle);
            }

            title ??= Text(customScreenTitle ?? item?.label ?? screenTitle ?? FlutterUI.translate("Loading..."));

            Color? headerColor;

            if (customScreen != null) {
              if (customScreen!.headerColorBuilder != null) {
                headerColor = customScreen!.headerColorBuilder!(context);
              }
            }
            else if (model != null) {
              if (model!.useScreenBackgroundInMenu) {
                headerColor = model!.background ?? Theme.of(context).colorScheme.surface;
              }
            }

            if (headerColor == null) {
              AppStyle appStyle = AppStyle.of(context);

              headerColor = ParseUtil.parseHexColor(appStyle.style(context, AppStyle.screenMenuTopColor));
            }

            PreferredSizeWidget? appBar = frame?.getAppBar(
                context: context,
                leading: leading,
                titleSpacing: leading != null ? 0 : 8,
                title: title,
                actions: actions,
                backgroundColor: isOffline && !OfflineUtil.isGoingOffline ? OfflineUtil.backgroundColor : headerColor
            );

            // Dummy body shown while loading/error.
            body ??= _buildDummyScreen(snapshot);

            Widget content;

            //In offline mode -> we don't use our pop handling to support custom pop handling (in custom screen)
            //otherwise this implementation would prevent custom pop handling because it fires before custom implementation
            if (_useOwnNavigation)
            {
              //If we replace WillPopScope with PopScope - maybe use !IUiService().usesNativeRouting(item!.screenLongName)

              // _onWillPop needs to access Scaffold.
              content = Builder(
                builder: (context) =>
                  PopScope(
                    canPop: _canPop(),
                    onPopInvokedWithResult: _onPopInvoked,
                    child: _wrapBody(body!))
              );
            }
            else {
              content = Builder(
                builder: (context) => _wrapBody(body!)
              );
            }

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

  ///Wraps the body (= screen) with a SafeArea or without if noSafeArea property is set
  Widget _wrapBody(Widget body) {
    Widget wrappedBody;

    if (model?.fullSize == true) {
      wrappedBody = body;
    } else {
      if (safeAreaColor != null) {
        wrappedBody = Container(
          color: safeAreaColor,
          child: SafeArea(
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: body,
            )
          )
        );
      }
      else {
        //we need a container with BoxDecoration around, because without we don't receive
        //events from [Listener]
        wrappedBody = Container(
          decoration: const BoxDecoration(),
          child: SafeArea(
            child: body
          )
        );
      }
    }

    if (body is WorkScreen) {
      //Use a listener to handle work-screen global events
      wrappedBody = Listener(
          onPointerDown: (event) {
            List<GlobalSubscription> copy = FlutterUI.globalSubscriptions();

            for (int i = 0; i < copy.length; i++) {
              copy[i].onTap?.call(event);
            }
          },
          child: wrappedBody
      );
    }

    return wrappedBody;
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

      safeAreaColor = customScreen.safeAreaColorBuilder?.call(context);
    }

    // Update screenTitle
    screenTitle = builtScreen.screenTitle;

    WorkScreen screen = WorkScreen(
      isOffline: isOffline && !OfflineUtil.isGoingOffline,
      item: item!,
      model: model,
      screen: builtScreen,
      updateSize: (size) {
        if (!sentScreenSizeForLayout) {
          // Trigger update synchronously for layout.
          _setScreenSize(size);
          sentScreenSizeForLayout = true;
        } else {
          subject.add(size);
        }
      },
    );

    WorkScreen.add(model?.name, screen);

    return screen;
  }

  void _setScreenSize(Size size) {
    ILayoutService()
        .setScreenSize(
      pScreenComponentId: model!.id,
      pSize: size,
    )
        .then((value) => value.forEach((e) async => await ICommandService().sendCommand(e)));
  }

  void _init() {
    // Send only if model is missing (which it always is in a custom screen) and the possible custom screen has send = true.
    final model = this.model;
    if (model == null &&
        (customScreen == null || (customScreen!.sendOpenScreenRequests && !IConfigService().offline.value))) {
      future = ICommandService().sendCommand(OpenScreenCommand(
        longName: item!.screenLongName,
        reason: "Screen was opened inside $runtimeType",
      ));
    } else if (model != null && kIsWeb) {
      future = ICommandService().sendCommand(
        ActivateScreenCommand(
          componentName: model.name,
          reason: "Screen was activated inside $runtimeType",
        ),
      );
    }

    future ??= Future.value(true);

    future!.then((success) {
      if (!success) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 350)).then((_) => _onBack());
        });
      }

      return null;
    });
  }

  void rebuild() {
    IUiService().closeJVxDialogs();

    Navigator.of(FlutterUI.getCurrentContext()!).popUntil((route) => route is! PopupRoute);

    sentScreenSizeForLayout = false;
    setState(() {});
  }

/*
  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }
    (context as Element).visitChildren(rebuild);
  }
*/
  Widget _buildDummyScreen(AsyncSnapshot<bool> snapshot) {
    Widget body;
    if (snapshot.connectionState == ConnectionState.none) {
      // Invalid screen name
      body = const ErrorScreen(
        message: "Screen not found.",
      );
    } else if (item?.screenLongName == null || (model == null && customScreen == null)) {
      // should route back on next frame; Don't visualize anything;
      body = const SizedBox.expand();
    } else if (snapshot.connectionState == ConnectionState.done && snapshot.data == false) {
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

  Widget? _buildLeading() {
    if (model?.isCloseAble == false) {
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

    // Calls _onWillPop -> call server, beam back or pop.
    if (mounted) {
      if (pForced && !_useOwnNavigation) {
        IUiService().routeToMenu();
        return;
      }

      await Navigator.maybePop(context);
    }
  }

  bool _canPop() {
    if (isNavigating || (LoadingBar.maybeOf(context)?.show ?? false)) {
      return false;
    }

    ScaffoldState? scaffoldState = Scaffold.maybeOf(context);

    if (scaffoldState != null && (scaffoldState.isDrawerOpen || scaffoldState.isEndDrawerOpen)) {
      return true; // Must pop drawer.
    }

    if (item?.screenLongName == null || (model == null && customScreen == null)) {
      return true;
    } else if (!IUiService().usesNativeRouting(item!.screenLongName)) {
      return false;
    }

    return true;
  }

  void _onPopInvoked(bool didPop, dynamic result) {
    if (didPop) return;

    isNavigating = true;

    try {
      if (item?.screenLongName == null || (model == null && customScreen == null)) {
        context.beamBack();
      } else if (!IUiService().usesNativeRouting(item!.screenLongName)) {
        BaseCommand commandToCloseScreen = _closeScreen();

        unawaited(IUiService().saveAllEditors(pReason: "Closing screen").then((success) {
          if (success) {
            unawaited(ICommandService().sendCommand(commandToCloseScreen));
          }
        }));
      }
      else {
        context.beamBack();
      }
    }
    finally {
      isForced = false;
      isNavigating = false;
    }
  }

  BaseCommand _closeScreen() {
    if (isForced) {
      return CloseScreenCommand(
        componentName: model!.name,
        reason: "Work screen back"
      );
    }

    return NavigationCommand(
      componentName: model!.name,
      reason: "Back button pressed"
    );
  }
}
