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

import 'package:beamer/beamer.dart';
import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_debug_overlay/flutter_debug_overlay.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart' hide LogEvent;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:universal_io/io.dart';

import 'config/app_config.dart';
import 'config/server_config.dart';
import 'custom/app_manager.dart';
import 'exceptions/error_view_exception.dart';
import 'mask/jvx_overlay.dart';
import 'mask/login/login.dart';
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
import 'util/extensions/jvx_logger_extensions.dart';
import 'util/extensions/list_extensions.dart';
import 'util/http_overrides.dart';
import 'util/image/image_loader.dart';
import 'util/import_handler/import_handler.dart';
import 'util/jvx_colors.dart';
import 'util/jvx_routes_observer.dart';
import 'util/loading_handler/loading_progress_handler.dart';
import 'util/parse_util.dart';
import 'util/widgets/future_nested_navigator.dart';

/// The base Widget representing the JVx to Flutter bridge.
class FlutterUI extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Determines the supported server version which will be sent in the [ApiStartupRequest]
  static const String supportedServerVersion = "3.1.0";

  /// Loads assets with packages prefix
  static bool package = true;

  /// Have we ever had a context?
  static bool initiated = false;

  /// Log Collector
  static final LogBucket logBucket = LogBucket();

  /// Request Collector
  static final HttpBucket httpBucket = HttpBucket();

  /// The default log level that is used before the config has been loaded.
  static const Level _defaultLogLevel = kDebugMode ? Level.info : Level.warning;

  /// The log filter used by [log].
  static final LogFilter _generalLogFilter = JVxFilter();

  /// The log filter used by [logAPI].
  static final LogFilter _apiLogFilter = JVxFilter();

  /// The log filter used by [logCommand].
  static final LogFilter _commandLogFilter = JVxFilter();

  /// The log filter used by [logUI].
  static final LogFilter _uiLogFilter = JVxFilter();

  /// The log filter used by [logLayout].
  static final LogFilter _layoutLogFilter = JVxFilter();

  /// General logger
  static final Logger log = Logger(
    level: _defaultLogLevel,
    filter: _generalLogFilter,
    printer: JVxPrettyPrinter(
      prefix: "GENERAL",
      printTime: true,
      methodCount: 0,
      errorMethodCount: 30,
    ),
  );

  /// API logger
  static final Logger logAPI = Logger(
    level: _defaultLogLevel,
    filter: _apiLogFilter,
    printer: JVxPrettyPrinter(
      prefix: "API",
      printTime: true,
      methodCount: 0,
      errorMethodCount: 30,
    ),
  );

  /// Command logger
  static final Logger logCommand = Logger(
    level: _defaultLogLevel,
    filter: _commandLogFilter,
    printer: JVxPrettyPrinter(
      prefix: "COMMAND",
      printTime: true,
      methodCount: 0,
      errorMethodCount: 30,
    ),
  );

  /// UI logger
  static final Logger logUI = Logger(
    level: _defaultLogLevel,
    filter: _uiLogFilter,
    printer: JVxPrettyPrinter(
      prefix: "UI",
      printTime: true,
      methodCount: 0,
      errorMethodCount: 30,
    ),
  );

  /// Layout logger
  static final Logger logLayout = Logger(
    level: _defaultLogLevel,
    filter: _layoutLogFilter,
    printer: SimplePrinter(
      colors: false,
      printTime: true,
    ),
  );

  /// The initial application configuration
  final AppConfig? appConfig;

  /// The application manager of this app.
  final AppManager? appManager;

  /// Builder function for custom splash widget
  final SplashBuilder? splashBuilder;

  /// Builder function for custom background.
  final WidgetBuilder? backgroundBuilder;

  /// Builder function for custom login widget
  final LoginBuilder? loginBuilder;

  /// Builder function for custom menu implementation.
  final MenuBuilder? menuBuilder;

  final List<Widget> debugOverlayEntries;

  static late PackageInfo packageInfo;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  const FlutterUI({
    super.key,
    this.appConfig,
    this.appManager,
    this.splashBuilder,
    this.backgroundBuilder,
    this.loginBuilder,
    this.menuBuilder,
    this.debugOverlayEntries = const [],
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

  static void resetPageBucket() {
    pageStorageBucket = PageStorageBucket();
  }

  static start([FlutterUI pAppToRun = const FlutterUI()]) async {
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

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Service init
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    // Apps
    IAppService appService = AppService.create();
    services.registerSingleton(appService);

    // Config
    IConfigService configController = ConfigService.create(
      configService: SharedPrefsHandler.create(sharedPrefs: await SharedPreferences.getInstance()),
      fileManager: await IFileManager.getFileManager(),
    );
    services.registerSingleton(configController);

    await appService.loadConfig();

    // Load config files
    AppConfig? devConfig;
    if (!kReleaseMode) {
      devConfig = await ConfigUtil.readDevConfig();
      if (devConfig != null) {
        FlutterUI.log.i("Found dev config, overriding values");
      }
    }

    AppConfig appConfig =
        const AppConfig.defaults().merge(pAppToRun.appConfig).merge(await ConfigUtil.readAppConfig()).merge(devConfig);

    // ?baseUrl=http%3A%2F%2Flocalhost%3A8888%2FJVx.mobile%2Fservices%2Fmobile&appName=demo
    Map<String, String> queryParameters = {...Uri.base.queryParameters};
    appConfig = appConfig.merge(_extractURIConfigParameters(queryParameters));

    await configController.loadConfig(appConfig, devConfig != null);

    _generalLogFilter.level = appConfig.logConfig?.levels?.general ?? _defaultLogLevel;
    _apiLogFilter.level = appConfig.logConfig?.levels?.api ?? _defaultLogLevel;
    _commandLogFilter.level = appConfig.logConfig?.levels?.command ?? _defaultLogLevel;
    _uiLogFilter.level = appConfig.logConfig?.levels?.ui ?? _defaultLogLevel;
    _layoutLogFilter.level = appConfig.logConfig?.levels?.layout ?? _defaultLogLevel;

    await IAppService().removeObsoletePredefinedApps();

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

    FlutterUIState.startupApp = await _handleURIParameters(queryParameters);
    queryParameters.forEach((key, value) => IConfigService().updateCustomStartupProperties(key, value));

    // API
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
}

late BeamerDelegate routerDelegate;

TransitionDelegate get transitionDelegate =>
    (kIsWeb ? const NoAnimationTransitionDelegate() as TransitionDelegate : const DefaultTransitionDelegate());

GlobalKey<NavigatorState>? splashNavigatorKey;

/// Global Bucket to persist the storage between different locations
PageStorageBucket pageStorageBucket = PageStorageBucket();

final RouteObserver<ModalRoute> routeObserver = RouteObserver();

class FlutterUIState extends State<FlutterUI> with WidgetsBindingObserver {
  static App? startupApp;

  final JVxRoutesObserver jvxRouteObserver = JVxRoutesObserver();

  AppLifecycleState? lastState;

  late ThemeData themeData;
  late ThemeData darkThemeData;

  final ThemeData splashTheme = JVxColors.applyJVxTheme(ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  ));

  late final StreamSubscription<ConnectivityResult> subscription;

  /// The last password that the user entered, used for offline switch.
  String? lastPassword;

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
      ),
      transitionDelegate: transitionDelegate,
      beamBackTransitionDelegate: transitionDelegate,
      guards: [
        // Guards / by beaming to /menu if an app is active
        BeamGuard(
          pathPatterns: ["/"],
          check: (context, location) =>
              IConfigService().currentApp.value == null || IAppService().exitFuture.value != null,
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
            parameters["returnUri"] = targetState.uri.path;
            return Uri(path: "/", queryParameters: parameters).toString();
          },
        ),
      ],
    );

    WidgetsBinding.instance.addObserver(this);
    subscription = Connectivity().onConnectivityChanged.listen(didChangeConnectivity);

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
    changedTheme();

    // Init
    if (startupApp != null) {
      IAppService().startApp(appId: startupApp!.id, autostart: true);
    } else {
      IAppService().startDefaultApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Locale> supportedLocales = {
      IConfigService().applicationLanguage.value,
      IConfigService().getPlatformLocale(),
      ...IConfigService().supportedLanguages.value,
      "en",
    }.whereNotNull().map((e) => Locale(e)).toList();

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
          locale: Locale(IConfigService().getLanguage()),
          supportedLocales: supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          routeInformationParser: BeamerParser(),
          routerDelegate: routerDelegate,
          backButtonDispatcher: BeamerBackButtonDispatcher(delegate: routerDelegate),
          title: title,
          builder: _routeBuilder,
        );
      },
    );
  }

  Widget _routeBuilder(BuildContext context, Widget? child) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        IAppService().startupFuture,
        IAppService().exitFuture,
      ]),
      child: child,
      builder: (context, child) {
        Widget futureBuilder = FutureBuilder(
          future: IAppService().startupFuture.value,
          builder: (context, startupSnapshot) => FutureBuilder(
            future: IAppService().exitFuture.value,
            builder: (context, exitSnapshot) {
              if ([ConnectionState.active, ConnectionState.waiting].contains(startupSnapshot.connectionState) ||
                  (startupSnapshot.connectionState == ConnectionState.done && startupSnapshot.hasError)) {
                retrySplash() => IAppService().startApp();
                splashReturnToApps() => IUiService().routeToAppOverview();

                return _buildSplash(
                  future: IAppService().startupFuture.value!,
                  retry: retrySplash,
                  returnToApps: splashReturnToApps,
                  childrenBuilder: (snapshot) => [
                    if (snapshot.connectionState == ConnectionState.done && snapshot.hasError)
                      _getStartupErrorDialog(
                        context,
                        snapshot,
                        retry: retrySplash,
                        returnToApps: splashReturnToApps,
                      ),
                  ],
                );
              }
              FlutterUI.initiated = true;

              if (startupSnapshot.connectionState == ConnectionState.none &&
                  ![ConnectionState.none, ConnectionState.done].contains(exitSnapshot.connectionState)) {
                return _buildExitSplash(child: JVxOverlay(child: child), future: IAppService().exitFuture.value!);
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
    Widget? child,
    List<Widget> Function(AsyncSnapshot snapshot)? childrenBuilder,
    required VoidCallback retry,
    required VoidCallback returnToApps,
  }) {
    return FutureNestedNavigator(
      theme: splashTheme,
      future: future,
      transitionDelegate: transitionDelegate,
      navigatorKey: splashNavigatorKey = GlobalObjectKey<NavigatorState>(future),
      builder: (context, snapshot) => Stack(
        children: [
          Splash(
            snapshot: snapshot,
            onReturn: returnToApps,
            splashBuilder: widget.splashBuilder ??
                (context, snapshot) => JVxSplash(
                      snapshot: snapshot,
                      logo: SvgPicture.asset(
                        ImageLoader.getAssetPath(FlutterUI.package, "assets/images/J.svg"),
                        width: 138,
                        height: 145,
                      ),
                      background: SvgPicture.asset(
                        ImageLoader.getAssetPath(FlutterUI.package, "assets/images/JVx_Bg.svg"),
                        fit: BoxFit.fill,
                      ),
                      branding: Image.asset(
                        ImageLoader.getAssetPath(FlutterUI.package, "assets/images/logo.png"),
                        width: 200,
                      ),
                    ),
          ),
          ...?childrenBuilder?.call(snapshot),
        ],
      ),
      child: child,
    );
  }

  /// Builds a widget to show when exiting an app.
  Widget _buildExitSplash({
    required Widget child,
    required Future future,
  }) {
    return FutureNestedNavigator(
      theme: splashTheme,
      future: Future.delayed(const Duration(milliseconds: 250)),
      transitionDelegate: transitionDelegate,
      builder: (context, delayedSnapshot) => Splash(
        snapshot: delayedSnapshot,
        splashBuilder: (context, delayedSnapshot) => JVxExitSplash(snapshot: delayedSnapshot),
      ),
      child: child,
    );
  }

  Future<void> didChangeConnectivity(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      FlutterUI.logAPI.i("Connectivity lost");
      var repository = IApiService().getRepository();
      if (repository is OnlineApiRepository && repository.connected) {
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
          ICommandService()
              .sendCommand(AliveCommand(reason: "App resumed from paused"))
              .catchError((e, stack) => FlutterUI.logAPI.w("Resume Alive Request failed", error: e, stackTrace: stack));
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

    IUiService().i18n().currentLanguage.removeListener(refresh);
    IUiService().layoutMode.removeListener(changedTheme);
    IConfigService().themePreference.removeListener(changedTheme);
    IConfigService().applicationStyle.removeListener(changedTheme);
    IUiService().applicationSettings.removeListener(refresh);

    super.dispose();
  }

  void changedTheme() {
    Map<String, String>? styleMap = IConfigService().applicationStyle.value;

    Color? styleColor = kIsWeb ? ParseUtil.parseHexColor(styleMap?['web.topmenu.color']) : null;
    styleColor ??= ParseUtil.parseHexColor(styleMap?['theme.color']);

    if (styleColor != null) {
      themeData = JVxColors.createTheme(styleColor, Brightness.light, useFixedPrimary: true);
      darkThemeData = JVxColors.createTheme(styleColor, Brightness.dark, useFixedPrimary: true);
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
    required VoidCallback returnToApps,
  }) {
    ErrorViewException? errorView = snapshot.error is ErrorViewException ? snapshot.error as ErrorViewException : null;

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
          title: Text(
            errorView?.errorCommand.title?.isNotEmpty ?? false
                ? errorView!.errorCommand.title!
                : FlutterUI.translateLocal("Error"),
          ),
          content: Text(
            errorView?.errorCommand.message ?? FlutterUI.translateLocal(IUiService.getErrorMessage(snapshot.error!)),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: returnToApps,
              child: Text(
                FlutterUI.translateLocal("Back"),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (!(errorView?.errorCommand.userError ?? false))
              TextButton(
                onPressed: retry,
                child: Text(
                  FlutterUI.translateLocal("Retry"),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

T? cast<T>(x) => x is T ? x : null;
