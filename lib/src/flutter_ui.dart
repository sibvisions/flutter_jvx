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

import 'dart:async';
import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_debug_overlay/flutter_debug_overlay.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart' hide LogEvent;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:push/push.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:universal_io/io.dart';

import 'commands.dart';
import 'config/app_config.dart';
import 'config/server_config.dart';
import 'custom/app_manager.dart';
import 'mask/login/login_handler.dart';
import 'mask/jvx_overlay.dart';
import 'mask/menu/menu.dart';
import 'mask/splash/jvx_exit_splash.dart';
import 'mask/splash/jvx_splash.dart';
import 'mask/splash/splash.dart';
import 'model/command/api/alive_command.dart';
import 'model/config/translation/i18n.dart';
import 'model/request/api_startup_request.dart';
import 'routing/locations/main_location.dart';
import 'service/api/i_api_service.dart';
import 'service/api/impl/default/api_service.dart';
import 'service/api/shared/controller/api_controller.dart';
import 'service/api/shared/repository/online_api_repository.dart';
import 'service/apps/app.dart';
import 'service/apps/i_app_service.dart';
import 'service/apps/impl/app_service.dart';
import 'service/command/i_command_service.dart';
import 'service/command/impl/command_service.dart';
import 'service/config/i_config_service.dart';
import 'service/config/impl/config_service.dart';
import 'service/config/shared/handler/shared_prefs_handler.dart';
import 'service/data/i_data_service.dart';
import 'service/data/impl/data_service.dart';
import 'service/file/file_manager.dart';
import 'service/layout/i_layout_service.dart';
import 'service/layout/impl/isolate/isolate_layout_service.dart';
import 'service/layout/impl/layout_service.dart';
import 'service/service.dart';
import 'service/storage/i_storage_service.dart';
import 'service/storage/impl/default/storage_service.dart';
import 'service/ui/i_ui_service.dart';
import 'service/ui/impl/ui_service.dart';
import 'util/config_util.dart';
import 'util/debug/jvx_debug.dart';
import 'util/jvx_logger.dart';
import 'util/extensions/list_extensions.dart';
import 'util/http_overrides.dart';
import 'util/image/image_loader.dart';
import 'util/import_handler/import_handler.dart';
import 'util/jvx_colors.dart';
import 'util/jvx_routes_observer.dart';
import 'util/loading_handler/loading_progress_handler.dart';
import 'util/parse_util.dart';
import 'util/push_util.dart';
import 'util/widgets/future_nested_navigator.dart';

T? cast<T>(x) => x is T ? x : null;

/// Builder function for dynamic color creation
typedef ColorBuilder = Color? Function(BuildContext context);

///Simple static application variables
class AppVariables {
  static Size? lastSize;

  static bool? lastDarkMode;
}

/// The base Widget representing the JVx to Flutter bridge.
class FlutterUI extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Determines the supported server version which will be sent in the [ApiStartupRequest]
  static const String supportedServerVersion = "4.0.0";

  /// Loads assets with packages prefix
  static bool package = true;

  /// Log Collector
  static final LogBucket logBucket = LogBucket();

  /// Request Collector
  static final HttpBucket httpBucket = HttpBucket();

  /// The default log level that is used before the config has been loaded.
  static const Level _defaultLogLevel = kDebugMode ? Level.info : Level.warning;

  /// The log filter used by [log].
  static final JVxFilter _generalLogFilter = JVxFilter(_defaultLogLevel);

  /// The log filter used by [logAPI].
  static final JVxFilter _apiLogFilter = JVxFilter(_defaultLogLevel);

  /// The log filter used by [logCommand].
  static final JVxFilter _commandLogFilter = JVxFilter(_defaultLogLevel);

  /// The log filter used by [logUI].
  static final JVxFilter _uiLogFilter = JVxFilter(_defaultLogLevel);

  /// The log filter used by [logLayout].
  static final JVxFilter _layoutLogFilter = JVxFilter(_defaultLogLevel);

  /// General logger
  static final JVxLogger log = JVxLogger(
    filter: _generalLogFilter,
    printer: PrefixPrinter(JVxPrettyPrinter(
      colors: false,
      prefix: "GENERAL",
      printTime: true,
      methodCount: 0,
      errorMethodCount: 30,
    )),
  );

  /// API logger
  static final JVxLogger logAPI = JVxLogger(
    filter: _apiLogFilter,
    printer: PrefixPrinter(JVxPrettyPrinter(
      colors: false,
      prefix: "API",
      printTime: true,
      methodCount: 0,
      errorMethodCount: 30,
    )),
  );

  /// Command logger
  static final JVxLogger logCommand = JVxLogger(
    filter: _commandLogFilter,
    printer: PrefixPrinter(JVxPrettyPrinter(
      colors: false,
      prefix: "COMMAND",
      printTime: true,
      methodCount: 0,
      errorMethodCount: 30,
    )),
  );

  /// UI logger
  static final JVxLogger logUI = JVxLogger(
    filter: _uiLogFilter,
    printer: PrefixPrinter(JVxPrettyPrinter(
      colors: false,
      prefix: "UI",
      printTime: true,
      methodCount: 0,
      errorMethodCount: 30,
    )),
  );

  /// Layout logger
  static final JVxLogger logLayout = JVxLogger(
    filter: _layoutLogFilter,
    printer: PrefixPrinter(SimplePrinter(
      colors: false,
      printTime: true,
    )),
  );

  /// The initial application configuration
  final AppConfig? appConfig;

  /// The application manager of this app.
  final AppManager? appManager;

  /// Builder function for custom splash widget
  final SplashBuilder? splashBuilder;

  /// Builder function for custom background.
  final WidgetBuilder? backgroundBuilder;

  /// Handler for custom login
  final LoginHandler? loginHandler;

  /// Builder function for custom menu implementation.
  final MenuBuilder? menuBuilder;

  final List<Widget> debugOverlayEntries;

  /// show or hide the debug banner in dev mode
  final bool debugBanner;

  /// Application metadata
  static late PackageInfo packageInfo;

  static final List<GlobalSubscription> _globalSubscriptions = [];

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  const FlutterUI({
    super.key,
    this.appConfig,
    this.appManager,
    this.splashBuilder,
    this.backgroundBuilder,
    this.loginHandler,
    this.menuBuilder,
    this.debugOverlayEntries = const [],
    this.debugBanner = true
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  @override
  FlutterUIState createState() => FlutterUIState();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Finds the [FlutterUIState] from the closest instance of this class that
  /// encloses the given context.
  static FlutterUIState of(BuildContext context) {
    final FlutterUIState? result = maybeOf(context);
    if (result != null) {
      return result;
    }
    throw FlutterError.fromParts([
      ErrorSummary(
        "FlutterUI.of() called with a context that does not contain a FlutterUI.",
      ),
      context.describeElement("The context used was"),
    ]);
  }

  /// Finds the [FlutterUIState] from the closest instance of this class that
  /// encloses the given context.
  ///
  /// If no instance of this class encloses the given context, will return null.
  /// To throw an exception instead, use [of] instead of this function.
  static FlutterUIState? maybeOf(BuildContext? context) {
    return context?.findAncestorStateOfType<FlutterUIState>();
  }

  /// Translates any text through the translation files loaded by the application.
  ///
  /// See also:
  /// * [I18n]
  /// * [IConfigService.getLanguage]
  static String translate(String? pText) {
    if (pText == null) return "";
    return IUiService().i18n().translate(pText);
  }

  /// Translates any text through the local-only translation files.
  ///
  /// See also:
  /// * [I18n]
  /// * [IConfigService.getLanguage]
  static String translateLocal(String? pText) {
    if (pText == null) return "";
    return IUiService().i18n().translateLocal(pText);
  }

  /// Creates an future error handler which prints the error + stackTrace
  /// to [FlutterUI.log] and throws the error.
  ///
  /// Intended do be use in [Future.catchError].
  static Function(Object error, StackTrace stackTrace) createErrorHandler(String pMessage) {
    return (error, stackTrace) {
      FlutterUI.log.e(pMessage, error: error, stackTrace: stackTrace);
      throw error;
    };
  }

  static BeamerDelegate getBeamerDelegate() {
    return routerDelegate;
  }

  /// Returns either the beamer context or the splash context, this SHOULD never be null under normal circumstances.
  ///
  /// See also:
  /// * [getCurrentContext]
  /// * [getSplashContext]
  static BuildContext? getEffectiveContext() {
    return getCurrentContext() ?? getSplashContext();
  }

  /// Returns the current beamer context, if present.
  static BuildContext? getCurrentContext() {
    return routerDelegate.navigatorKey.currentContext;
  }

  /// Returns the context of the navigator while we are in the splash.
  static BuildContext? getSplashContext() {
    return splashNavigatorKey?.currentContext;
  }

  /// Clears the global beaming history.
  ///
  /// Uses [JVxListExtension.removeAllExceptLast] because the "history" also contains the present.
  static void clearHistory() {
    routerDelegate.beamingHistory.removeAllExceptLast();
  }

  /// Clears the location beaming history.
  ///
  /// This is only to be done AFTER routing to a new page, as before routing,
  /// the now past location would have not benn counted as "history".
  ///
  /// Uses [JVxListExtension.removeAllExceptLast] because the "history" also contains the present.
  static void clearLocationHistory() {
    routerDelegate.currentBeamLocation.history.removeAllExceptLast();
  }

  /// Clears all service depending on [reason].
  ///
  /// This **can not** be called with [ClearReason.LOGOUT] from within a command processing
  /// as the command service then awaits its queue and would therefore end up in a deadlock.
  static FutureOr<void> clearServices(ClearReason reason) async {
    await ILayoutService().clear(reason);
    await IStorageService().clear(reason);
    await IDataService().clear(reason);
    await IUiService().clear(reason);
    await ICommandService().clear(reason);
    await IApiService().clear(reason);
    await IConfigService().clear(reason);
    await IAppService().clear(reason);
  }

  static start([FlutterUI pAppToRun = const FlutterUI()]) async {
    SimplePrinter.levelPrefixes[Level.debug] = '';
    SimplePrinter.levelPrefixes[Level.warning] = '';
    SimplePrinter.levelPrefixes[Level.trace] = '';
    SimplePrinter.levelPrefixes[Level.info] = '';
    SimplePrinter.levelPrefixes[Level.error] = '';
    SimplePrinter.levelPrefixes[Level.fatal] = '';

    WidgetsFlutterBinding.ensureInitialized();

    Logger.addOutputListener((event) {
      LogLevel? level = LogLevel.values.firstWhereOrNull((element) => element.name == event.origin.level.name);
      if (level == null) return;
      logBucket.add(LogEvent(
        level: level,
        message: event.origin.message,
        error: event.origin.error,
        stackTrace: event.origin.stackTrace,
        time: event.origin.time,
      ));
    });

    BrowserHttpClientException.verbose = !kReleaseMode;

    await PushUtil.localNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings("@mipmap/ic_launcher"),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (details) {
        var state = FlutterUI.maybeOf(FlutterUI.getEffectiveContext());
        if (state != null) {
          PushUtil.handleLocalNotificationTap(state.tappedNotificationPayloads, details);
        }
      },
    );

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Service init
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    // Apps
    IAppService appService = AppService.create();
    services.registerSingleton(appService);

    // Config
    IConfigService configService = ConfigService.create(
      configHandler: SharedPrefsHandler.create(sharedPrefs: await SharedPreferences.getInstance()),
      fileManager: await IFileManager.getFileManager(),
    );
    services.registerSingleton(configService);

    // Load config files

    AppConfig? appConfig = await ConfigUtil.readAppConfig();

    if (appConfig != null) {
      if (kDebugMode) {
        print("Found app config, will merge and override static config!");
      }
    }

    AppConfig? devConfig;
    if (!kReleaseMode) {
      devConfig = await ConfigUtil.readDevConfig();
      if (devConfig != null) {
        if (kDebugMode) {
          print("Found dev config, will merge and override static config!");
        }
      }
    }

    appConfig = const AppConfig.defaults().merge(pAppToRun.appConfig).merge(appConfig).merge(devConfig);

    // ?baseUrl=http%3A%2F%2Flocalhost%3A8888%2FJVx.mobile%2Fservices%2Fmobile&appName=demo
    Map<String, String> queryParameters = {...Uri.base.queryParameters};
    appConfig = appConfig.merge(_extractURIConfigParameters(queryParameters));

    await configService.loadConfig(appConfig, devConfig != null);

    await appService.removeObsoletePredefinedApps();
    await appService.refreshStoredApps();

    // dev config always overrides default app
    await configService.refreshDefaultApp(devConfig != null);

    _generalLogFilter.level = appConfig.logConfig?.levels?.general ?? _defaultLogLevel;
    _apiLogFilter.level = appConfig.logConfig?.levels?.api ?? _defaultLogLevel;
    _commandLogFilter.level = appConfig.logConfig?.levels?.command ?? _defaultLogLevel;
    _uiLogFilter.level = appConfig.logConfig?.levels?.ui ?? _defaultLogLevel;
    _layoutLogFilter.level = appConfig.logConfig?.levels?.layout ?? _defaultLogLevel;

    // Layout
    ILayoutService layoutService = kIsWeb ? LayoutService.create() : await IsolateLayoutService.create();
    services.registerSingleton(layoutService);

    // Storage
    IStorageService storageService = StorageService.create();
    services.registerSingleton(storageService);

    // Data
    IDataService dataService = DataService.create();
    services.registerSingleton(dataService);

    // Command
    ICommandService commandService = CommandService.create();
    services.registerSingleton(commandService);
    (commandService as CommandService).progressHandler.add(LoadingProgressHandler());

    // UI
    IUiService uiService = UiService.create();
    services.registerSingleton(uiService);

    App? urlApp = await _handleURIParameters(queryParameters);

    // API
    //always online repository because app service will set the right repository
    IApiService apiService = ApiService.create(OnlineApiRepository());
    apiService.setController(ApiController());
    services.registerSingleton(apiService);

    packageInfo = await PackageInfo.fromPlatform();

    fixUrlStrategy();

    tz.initializeTimeZones();

    if (!kIsWeb) {
      HttpOverrides.global = JVxHttpOverrides();
    }

    // Init translation
    await IConfigService().reloadSupportedLanguages();
    await IUiService().i18n().setLanguage(IConfigService().getLanguage());
    IUiService().setAppManager(pAppToRun.appManager);

    await pAppToRun.appManager?.init();

    if (urlApp != null) {
      FlutterUIState.startupApp = urlApp;
      configService.setCustomStartupProperties(queryParameters);
    } else if (!kIsWeb) {
      // Handle notification launching app from terminated state
      Map<String?, Object?>? data = await Push.instance.notificationTapWhichLaunchedAppFromTerminated;
      data = PushUtil.extractJVxData(data);
      // "payload" means it's a local notification, handle below.
      if (data?.containsKey("payload") ?? false) data = null;
      if (data == null) {
        var notificationLaunchDetails = await PushUtil.localNotificationsPlugin.getNotificationAppLaunchDetails();
        if (notificationLaunchDetails?.didNotificationLaunchApp ?? false) {
          var payload = notificationLaunchDetails!.notificationResponse?.payload;
          if (payload != null) {
            try {
              data = jsonDecode(payload);
            } catch (e, stack) {
              FlutterUI.log.f("Failed to parse notification payload", error: e, stackTrace: stack);
            }
          }
        }
      }

      if (data != null) {
        FlutterUI.log.d("App launched from notification");
        PushUtil.notificationWhichLaunchedApp = data;
        var notificationConfig = PushUtil.handleNotificationData(data);
        if (notificationConfig != null) {
          App notificationApp = await App.createAppFromConfig(notificationConfig);
          FlutterUIState.startupApp = notificationApp;
        }
      }
    }

    FlutterUIState.startupApp ??= IAppService().getStartupApp();

    runApp(pAppToRun);
  }

  static AppConfig? _extractURIConfigParameters(Map<String, String> queryParameters) {
    Duration? tryParseDuration(String? parameter) {
      if (parameter != null) {
        int? parsedParameter = int.tryParse(parameter);
        if (parsedParameter != null) {
          return Duration(milliseconds: parsedParameter);
        }
      }
      return null;
    }

    return AppConfig(
      requestTimeout: tryParseDuration(queryParameters.remove("requestTimeout")),
      aliveInterval: tryParseDuration(queryParameters.remove("aliveInterval")),
      wsPingInterval: tryParseDuration(queryParameters.remove("wsPingInterval")),
    );
  }

  static Future<App?> _handleURIParameters(Map<String, String> queryParameters) async {
    String? mobileOnly = queryParameters.remove("mobileOnly");
    if (mobileOnly != null) {
      IUiService().updateMobileOnly(mobileOnly == "true");
    }
    String? webOnly = queryParameters.remove("webOnly");
    if (webOnly != null) {
      IUiService().updateWebOnly(webOnly == "true");
    }

    ServerConfig? urlConfig = ParseUtil.extractAppParameters(queryParameters);
    if (urlConfig != null) {
      App urlApp = await App.createAppFromConfig(urlConfig);
      await urlApp.updateDefault(true);

      await IConfigService().updateCurrentApp(urlApp.id);
      if (IConfigService().currentApp.value != null) {
        String? language = queryParameters.remove("language");
        if (language != null) {
          await IConfigService().updateUserLanguage(
            language == IConfigService().getPlatformLocale() ? null : language,
          );
        }
        String? timeZone = queryParameters.remove("timeZone");
        if (timeZone != null) {
          await IConfigService().updateApplicationTimeZone(timeZone);
        }
      }
      return urlApp;
    }

    return null;
  }

  /// Registers a global subscription
  static void registerGlobalSubscription(GlobalSubscription pSubscription) {
    if (!_globalSubscriptions.contains(pSubscription)) {
      _globalSubscriptions.add(pSubscription);
    }
  }

  /// Disposes a global subscription
  static void disposeGlobalSubscription(Object pSubscriber) {
    _globalSubscriptions.remove(pSubscriber);
  }

  static List<GlobalSubscription> globalSubscriptions() {
    //Return a copy to avoid concurrent modification problems
    return _globalSubscriptions.toList(growable: false);
  }

}

late BeamerDelegate routerDelegate;

TransitionDelegate get transitionDelegate =>
    (kIsWeb ? const NoAnimationTransitionDelegate() as TransitionDelegate : const DefaultTransitionDelegate());

GlobalKey<NavigatorState>? splashNavigatorKey;

final RouteObserver<ModalRoute> routeObserver = RouteObserver();

class FlutterUIState extends State<FlutterUI> with WidgetsBindingObserver {
  static App? startupApp;

  final JVxRoutesObserver jvxRouteObserver = JVxRoutesObserver();

  AppLifecycleState? lastState;

  PageStorageBucket _storageBucket = PageStorageBucket();

  late ThemeData themeData;
  late ThemeData darkThemeData;

  final ThemeData splashThemeDefault = JVxColors.applyJVxTheme(ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  ));

  late final StreamSubscription<List<ConnectivityResult>> subscription;

  /// The last password that the user entered, used for offline switch.
  String? lastPassword;

  late final VoidCallback newTokenSubscription;
  late final VoidCallback notificationTapSubscription;
  late final ValueNotifier<List<Map<String?, Object?>>> tappedNotificationPayloads;
  late final VoidCallback notificationSubscription;
  late final ValueNotifier<List<RemoteMessage>> messagesReceived;
  late final VoidCallback backgroundNotificationSubscription;
  late final ValueNotifier<List<RemoteMessage>> backgroundMessagesReceived;

  @override
  void initState() {
    super.initState();

    routerDelegate = BeamerDelegate(
      setBrowserTabTitle: false,
      navigatorObservers: [routeObserver, jvxRouteObserver],
      locationBuilder: BeamerLocationBuilder(
        beamLocations: [
          MainLocation(),
        ],
      ).call,
      transitionDelegate: transitionDelegate,
      beamBackTransitionDelegate: transitionDelegate,
      guards: [
        // Guards AppOverview (/) by beaming to /home if an app is active
        BeamGuard(
          pathPatterns: ["/"],
          check: (context, location) {
            // This check must not enforce a more restrictive test than AppService#startCustomApp!
            var deepLinkId = App.computeIdFromConfig(
                ParseUtil.extractAppParameters(Map.of((location.state as BeamState).queryParameters)));

            return (deepLinkId != null && IConfigService().currentApp.value != deepLinkId) ||
                IConfigService().currentApp.value == null ||
                IAppService().exitFuture.value != null;
          },
          beamToNamed: (origin, target) => "/home",
        ),
        // Guards everything except / and /settings (e.g. /menu) by beaming to / if there is no active app
        BeamGuard(
          guardNonMatching: true,
          pathPatterns: ["/", "/settings"],
          check: (context, location) =>
              IConfigService().currentApp.value != null && IAppService().exitFuture.value == null,
          beamToNamed: (origin, target) {
            BeamState targetState = target.state as BeamState;
            var parameters = Map.of(targetState.queryParameters);
            parameters[MainLocation.returnUriKey] = targetState.uri.path;

            return Uri(path: "/", queryParameters: parameters).toString();
          },
        ),
      ],
    );

    WidgetsBinding.instance.addObserver(this);
    subscription = Connectivity().onConnectivityChanged.listen(didChangeConnectivity);

    if (!kIsWeb) {
      registerPushStreams();
    }

    // Register callbacks
    IConfigService().disposeImagesCallbacks();
    IConfigService().registerImagesCallback(refresh);

    // Update style to reflect web colors for theme
    // Don't forget to remove them in [dispose]!
    // ignore: invalid_use_of_protected_member
    assert(!IUiService().layoutMode.hasListeners);
    IUiService().layoutMode.addListener(changedTheme);
    IConfigService().themePreference.addListener(changedTheme);
    IConfigService().applicationStyle.addListener(changedTheme);
    IUiService().applicationSettings.addListener(refresh);
    IUiService().i18n().currentLanguage.addListener(refresh);

    // Init default themes (if applicable)
    changeTheme(null);

    // Let Flutter build it once, so we can access the context.
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // Init
      if (startupApp != null) {
        IAppService().startApp(appId: startupApp!.id, autostart: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    AppVariables.lastSize ??= AppVariables.lastSize = MediaQuery.sizeOf(context);
    AppVariables.lastDarkMode ??= MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    List<Locale> supportedLocales = {
      IConfigService().applicationLanguage.value,
      IConfigService().getPlatformLocale(),
      ...IConfigService().supportedLanguages.value,
      "en",
    }.nonNulls.map((e) => Locale(e)).toList();

    return ListenableBuilder(
      listenable: Listenable.merge([
        IUiService().applicationParameters,
        IConfigService().applicationStyle,
      ]),
      builder: (context, _) {
        String title = (kIsWeb ? IUiService().applicationParameters.value.applicationTitleWeb : null) ??
            widget.appConfig?.title ??
            FlutterUI.packageInfo.appName;
        return MaterialApp.router(
          themeMode: IConfigService().getThemeMode(),
          theme: themeData,
          darkTheme: darkThemeData,
          themeAnimationDuration: Duration.zero,
          locale: Locale(IConfigService().getLanguage()),
          supportedLocales: supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          routeInformationParser: BeamerParser(),
          routerDelegate: routerDelegate,
          backButtonDispatcher: BeamerBackButtonDispatcher(delegate: routerDelegate),
          title: title,
          builder: _routeBuilder,
          debugShowCheckedModeBanner: widget.debugBanner,
        );
      },
    );
  }

  Widget _routeBuilder(BuildContext contextA, Widget? child) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        IAppService().startupFuture,
        IAppService().exitFuture,
      ]),
      child: child,
      builder: (contextB, child) {
        Widget futureBuilder = FutureBuilder(
          future: IAppService().startupFuture.value,
          builder: (contextC, startupSnapshot) => FutureBuilder(
            future: IAppService().exitFuture.value,
            builder: (contextD, exitSnapshot) {
              if ([ConnectionState.active, ConnectionState.waiting].contains(startupSnapshot.connectionState) ||
                  (startupSnapshot.connectionState == ConnectionState.done && startupSnapshot.hasError)) {
                retrySplash() => IAppService().startApp();

                VoidCallback? returnToApps =
                    IUiService().canRouteToAppOverview() ? IUiService().routeToAppOverview : null;

                return _buildSplash(
                  future: IAppService().startupFuture.value!,
                  context: contextD,
                  retry: retrySplash,
                  returnToApps: returnToApps,
                  childrenBuilder: (snapshot) => [
                    if (snapshot.connectionState == ConnectionState.done && snapshot.hasError)
                      _getStartupErrorDialog(
                        contextD,
                        snapshot,
                        retry: retrySplash,
                        returnToApps: returnToApps,
                      ),
                  ],
                );
              }

              if (startupSnapshot.connectionState == ConnectionState.none &&
                  ![ConnectionState.none, ConnectionState.done].contains(exitSnapshot.connectionState)) {
                return _buildExitSplash(future: IAppService().exitFuture.value!,
                                        context: contextD,
                                        child: JVxOverlay(child: child));
              }

              if (startupApp != null &&
                  startupSnapshot.connectionState == ConnectionState.none &&
                  exitSnapshot.connectionState == ConnectionState.none) {
                return Visibility.maintain(visible: false, child: JVxOverlay(child: child));
              }

              return JVxOverlay(child: child);
            },
          ),
        );

        // Former debug overlay is available under cc4f5fd9f82ce0ce8c4894ce3ae59c63f3319d83
        return DebugOverlay(
          opacity: 0.95,
          logBucket: FlutterUI.logBucket,
          httpBucket: FlutterUI.httpBucket,
          debugEntries: [
            const JVxDebug(),
            ...widget.debugOverlayEntries,
            const UIDebug(),
          ],
          child: futureBuilder,
        );
      },
    );
  }

  /// Builds a widget to show when starting an app.
  Widget _buildSplash({
    required Future future,
    BuildContext? context,
    Widget? child,
    List<Widget> Function(AsyncSnapshot snapshot)? childrenBuilder,
    required VoidCallback retry,
    required VoidCallback? returnToApps,
  }) {
    return FutureNestedNavigator(
      theme: _splashTheme(context),
      future: future,
      transitionDelegate: transitionDelegate,
      navigatorKey: splashNavigatorKey = GlobalObjectKey<NavigatorState>(future),
      builder: (contextA, snapshot) => Stack(
        children: [
          Splash(
            snapshot: snapshot,
            onReturn: returnToApps,
            splashBuilder: widget.splashBuilder ??
                (contextB, snapshot) {
                  return JVxSplash(
                    snapshot: snapshot,
                    logo: SvgPicture.asset(
                      ImageLoader.getAssetPath(FlutterUI.package,
                          JVxColors.isLightTheme(contextB) ?
                          "assets/images/J.svg" :
                          "assets/images/J_dark.svg"),
                      width: 138,
                      height: 145,
                    ),
                    background: SvgPicture.asset(
                      ImageLoader.getAssetPath(FlutterUI.package,
                          JVxColors.isLightTheme(contextB) ?
                          "assets/images/JVx_Bg.svg" :
                          "assets/images/JVx_Bg_dark.svg"),
                      fit: BoxFit.fill,
                    ),
                    branding: Image.asset(
                      ImageLoader.getAssetPath(FlutterUI.package,
                          JVxColors.isLightTheme(contextB) ?
                          "assets/images/logo.png" :
                          "assets/images/logo_dark.png"
                      ),
                      width: 200,
                    ),
                  );
                },
          ),
          ...?childrenBuilder?.call(snapshot),
        ],
      ),
      child: child,
    );
  }

  /// Builds a widget to show when exiting an app.
  Widget _buildExitSplash({
    required Future future,
    BuildContext? context,
    required Widget child
  }) {
    return FutureNestedNavigator(
      theme: _splashTheme(context),
      future: Future.delayed(const Duration(milliseconds: 250)),
      transitionDelegate: transitionDelegate,
      builder: (contextA, delayedSnapshot) => Splash(
        snapshot: delayedSnapshot,
        splashBuilder: (contextB, delayedSnapshot) => JVxExitSplash(snapshot: delayedSnapshot),
      ),
      child: child,
    );
  }

  ThemeData _splashTheme(BuildContext? context) {
    return context != null ? Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: JVxColors.isLightTheme(context) ? JVxColors.blue : Colors.black,
            primary: JVxColors.isLightTheme(context) ? JVxColors.blue : Colors.black54,
            brightness: Theme.of(context).brightness)) : splashThemeDefault;
  }

  Future<void> didChangeConnectivity(List<ConnectivityResult> result) async {
    if (result.contains(ConnectivityResult.none)) {
      FlutterUI.logAPI.i("Connectivity lost");

      var repository = IApiService().getRepository();

      if (repository is OnlineApiRepository) {
        if (repository.connected) {
          // Workaround for https://github.com/dart-lang/sdk/issues/47807
          if (Platform.isIOS) {
            // Force close sockets
            await repository.stop();
            await repository.start();
            try {
              await repository.startWebSocket();
            } catch (_) {
              // Expected to throw, triggers reconnect.
            }
            repository.setConnected(true);
          }
          repository.setConnected(false);
        }
      }
    }
    else if (result.contains(ConnectivityResult.wifi)
             || result.contains(ConnectivityResult.ethernet)) {
      FlutterUI.logAPI.i("Connectivity is back");

      var repository = IApiService().getRepository();

      if (repository is OnlineApiRepository) {
        if (!repository.connected) {
          repository.setConnected(true);
        }
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    _checkAlive(state);
  }

  /// If the app is resumed, resumes alive interval and triggers an [AliveCommand] to check server session.
  ///
  /// Ignores [AppLifecycleState.inactive] as it is not really reliable on different platforms.
  /// * iOS: inactive -> paused -> inactive -> resumed
  /// * Android: inactive -> paused -> resumed
  void _checkAlive(AppLifecycleState state) {
    var repository = IApiService().getRepository();
    if (repository is OnlineApiRepository) {
      // Stop and reset alive timer.
      repository.resetAliveInterval();
      repository.jvxWebSocket?.resetPingInterval();
    }

    if (lastState != null) {
      if (lastState == AppLifecycleState.paused && state == AppLifecycleState.resumed) {
        // App was resumed from a paused state (Permission overlay is not paused)
        if (IUiService().clientId.value != null && !IConfigService().offline.value) {
          ICommandService().sendCommand(AliveCommand(reason: "App resumed from paused"), showDialogOnError: false);
        }
      }
    }

    if (state != AppLifecycleState.inactive) {
      lastState = state;
    }
  }

  @override
  void dispose() {
    widget.appManager?.dispose();

    IApiService().getRepository().stop();
    subscription.cancel();
    WidgetsBinding.instance.removeObserver(this);

    if (!kIsWeb) {
      disposePushStreams();
    }

    IUiService().i18n().currentLanguage.removeListener(refresh);
    IUiService().layoutMode.removeListener(changedTheme);
    IConfigService().themePreference.removeListener(changedTheme);
    IConfigService().applicationStyle.removeListener(changedTheme);
    IUiService().applicationSettings.removeListener(refresh);

    super.dispose();
  }

  /// The global [PageStorageBucket].
  ///
  /// This bucket survives app (re-)starts.
  ///
  /// See also:
  /// * [resetGlobalStorageBucket]
  /// * [JVxOverlayState.storageBucket]
  PageStorageBucket get globalStorageBucket => _storageBucket;

  /// Resets the [globalStorageBucket].
  ///
  /// See also:
  /// * [JVxOverlayState.resetStorageBucket]
  void resetGlobalStorageBucket() {
    _storageBucket = PageStorageBucket();
  }

  void changedTheme() {
    Map<String, String>? styleMap = IConfigService().applicationStyle.value;

    if (styleMap != null) {
      Color? styleColor = kIsWeb ? ParseUtil.parseHexColor(styleMap['web.topmenu.color']) : null;
      styleColor ??= ParseUtil.parseHexColor(styleMap['theme.color']);

      changeTheme(styleColor);
    }
    else {
      refresh();
    }
  }

  void changeTheme(Color? pColor) {
    if (pColor != null) {
      themeData = JVxColors.createTheme(pColor, Brightness.light, useFixedPrimary: true);
      darkThemeData = JVxColors.createTheme(pColor, Brightness.dark, useFixedPrimary: true);
    } else {
      themeData = JVxColors.createTheme(Colors.blue, Brightness.light);
      darkThemeData = JVxColors.createTheme(Colors.blue, Brightness.dark);
    }
    setState(() {});
  }

  void refresh() {
    setState(() {});
  }

  static Widget _getStartupErrorDialog(
    BuildContext context,
    AsyncSnapshot<dynamic> snapshot, {
    required VoidCallback retry,
    required VoidCallback? returnToApps,
  }) {
    OpenServerErrorDialogCommand? serverError =
        snapshot.error is OpenServerErrorDialogCommand ? snapshot.error as OpenServerErrorDialogCommand : null;

    Object? error = snapshot.error!;
    if (error is ErrorCommand) {
      error = error.error;
    }

    var actions = [
      if (returnToApps != null)
        TextButton(
          onPressed: returnToApps,
          child: Text(
            FlutterUI.translateLocal("Back"),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      if (serverError?.invalidApp != true)
        TextButton(
          onPressed: retry,
          child: Text(
            FlutterUI.translateLocal("Retry"),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
    ];
    return Stack(
      children: [
        const Opacity(
          opacity: 0.7,
          child: ModalBarrier(
            dismissible: false,
            color: Colors.black54,
          ),
        ),
        AlertDialog(
          //this is important because the Theme is not correct in build of AlertDialog
          shape: Theme.of(context).dialogTheme.shape,
          surfaceTintColor: Theme.of(context).dialogTheme.surfaceTintColor,

          title: Text(
            serverError?.title?.isNotEmpty ?? false ? serverError!.title! : FlutterUI.translateLocal("Error"),
          ),
          content: Text(
            serverError?.message ?? FlutterUI.translateLocal(IUiService.getErrorMessage(error)),
          ),
          actionsAlignment: actions.length > 1 ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
          actions: actions,
        ),
      ],
    );
  }

  void registerPushStreams() {
    tappedNotificationPayloads = ValueNotifier([]);
    messagesReceived = ValueNotifier([]);
    backgroundMessagesReceived = ValueNotifier([]);

    newTokenSubscription = Push.instance.addOnNewToken(PushUtil.handleTokenUpdates);

    notificationTapSubscription = Push.instance.addOnNotificationTap((data) {
      // "payload" means it's a local notification, handle elsewhere.
      if (data.containsKey("payload")) return;

      PushUtil.handleNotificationTap(tappedNotificationPayloads, data);
    });

    notificationSubscription = Push.instance.addOnMessage((message) {
      PushUtil.handleOnMessage(messagesReceived, message);
    });

    backgroundNotificationSubscription = Push.instance.addOnBackgroundMessage((message) {
      PushUtil.handleOnBackgroundMessages(backgroundMessagesReceived, message);
    });
  }

  void disposePushStreams() {
    newTokenSubscription();
    notificationTapSubscription();
    notificationSubscription();
    backgroundNotificationSubscription();

    tappedNotificationPayloads.dispose();
    messagesReceived.dispose();
    backgroundMessagesReceived.dispose();
  }
}

typedef OnTapCallback = void Function([PointerEvent? pEvent]);

/// Used for subscribing in [JVxOverlay] to receive data.
@immutable
class GlobalSubscription {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Reference to creator of this subscription
  final Object subbedObj;

  /// Callback will be called with selected row.
  final OnTapCallback? onTap;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const GlobalSubscription({
    required this.subbedObj,
    this.onTap,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  bool same(GlobalSubscription subscription) {
    return subscription.subbedObj == subbedObj;
  }

}
