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
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_debug_overlay/flutter_debug_overlay.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
import 'mask/splash/splash.dart';
import 'model/command/api/alive_command.dart';
import 'model/command/api/login_command.dart';
import 'model/config/application_parameters.dart';
import 'model/config/translation/i18n.dart';
import 'model/request/api_startup_request.dart';
import 'routing/locations/app_location.dart';
import 'routing/locations/login_location.dart';
import 'routing/locations/menu_location.dart';
import 'routing/locations/settings_location.dart';
import 'routing/locations/work_screen_location.dart';
import 'service/api/i_api_service.dart';
import 'service/api/impl/default/api_service.dart';
import 'service/api/shared/controller/api_controller.dart';
import 'service/api/shared/repository/online_api_repository.dart';
import 'service/apps/app.dart';
import 'service/apps/app_service.dart';
import 'service/command/i_command_service.dart';
import 'service/command/impl/command_service.dart';
import 'service/config/config_controller.dart';
import 'service/config/config_service.dart';
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
import 'util/import_handler/import_handler.dart';
import 'util/jvx_colors.dart';
import 'util/loading_handler/loading_progress_handler.dart';
import 'util/parse_util.dart';
import 'util/route_observer.dart';

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

  /// The initial application configuration
  final AppConfig? appConfig;

  /// The application manager of this app.
  final AppManager? appManager;

  /// Builder function for custom splash widget
  final SplashBuilder? splashBuilder;

  /// Builder function for custom background.
  final WidgetBuilder? backgroundBuilder;

  /// Builder function for custom login widget
  final Widget Function(BuildContext context, LoginMode mode)? loginBuilder;

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
  /// * [ConfigController.getLanguage]
  static String translate(String? pText) {
    if (pText == null) return "";
    return IUiService().i18n().translate(pText);
  }

  /// Translates any text through the local-only translation files.
  ///
  /// See also:
  /// * [I18n]
  /// * [ConfigController.getLanguage]
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
      FlutterUI.log.e(pMessage, error, stackTrace);
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

  static void clearHistory() {
    // Beamer's history also contains the present!
    routerDelegate.beamingHistory.removeAllExceptLast();
  }

  static void clearLocationHistory() {
    // We have to clear the history only after routing, as before the past location would have not benn counted as "history".
    routerDelegate.currentBeamLocation.history.removeAllExceptLast();
  }

  /// Clears all service depending on [pFullClear].
  ///
  /// When [pFullClear] is `true`, then a full app restart/change happened.
  /// If `false`, just a logout.
  ///
  /// This can not be called with [pFullClear] = `true` from within a command processing
  /// as the command service then awaits its queue and would therefore end up in a deadlock.
  static FutureOr<void> clearServices(bool pFullClear) async {
    await ILayoutService().clear(pFullClear);
    await IStorageService().clear(pFullClear);
    await IDataService().clear(pFullClear);
    await IUiService().clear(pFullClear);
    await ICommandService().clear(pFullClear);
    await IApiService().clear(pFullClear);
  }

  static void resetPageBucket() {
    pageStorageBucket = PageStorageBucket();
  }

  static start([FlutterUI pAppToRun = const FlutterUI()]) async {
    WidgetsFlutterBinding.ensureInitialized();

    Logger.addOutputListener((event) {
      logBucket.add(LogEvent(
        level: LogLevel.values.firstWhere((element) => element.name == event.origin.level.name),
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
    AppService appService = AppService.create();
    services.registerSingleton(appService);

    // Config
    ConfigController configController = ConfigController.create(
      configService: ConfigService.create(sharedPrefs: await SharedPreferences.getInstance()),
      fileManager: await IFileManager.getFileManager(),
    );
    services.registerSingleton(configController);

    // Load config files
    AppConfig? devConfig;
    if (!kReleaseMode) {
      devConfig = await ConfigUtil.readDevConfig();
      if (devConfig != null) {
        FlutterUI.log.i("Found dev config, overriding values");
      }
    }

    AppConfig appConfig =
        const AppConfig.empty().merge(pAppToRun.appConfig).merge(await ConfigUtil.readAppConfig()).merge(devConfig);

    // ?baseUrl=http%3A%2F%2Flocalhost%3A8888%2FJVx.mobile%2Fservices%2Fmobile&appName=demo
    Map<String, String> queryParameters = {...Uri.base.queryParameters};
    appConfig = appConfig.merge(_extractURIConfigParameters(queryParameters));

    await configController.loadConfig(appConfig, devConfig != null);

    _generalLogFilter.level = appConfig.logConfig?.levels?.general ?? _defaultLogLevel;
    _apiLogFilter.level = appConfig.logConfig?.levels?.api ?? _defaultLogLevel;
    _commandLogFilter.level = appConfig.logConfig?.levels?.command ?? _defaultLogLevel;
    _uiLogFilter.level = appConfig.logConfig?.levels?.ui ?? _defaultLogLevel;

    await AppService().removeObsoletePredefinedApps();

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

    FlutterUIState.urlConfig = await _extractURIParameters(queryParameters);
    queryParameters.forEach((key, value) => ConfigController().updateCustomStartupProperties(key, value));

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
    await ConfigController().reloadSupportedLanguages();
    await IUiService().i18n().setLanguage(ConfigController().getLanguage());
    IUiService().setAppManager(pAppToRun.appManager);

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

  static Future<App?> _extractURIParameters(Map<String, String> queryParameters) async {
    App? urlApp;

    String? appName = queryParameters.remove("appName");
    String? baseUrl = queryParameters.remove("baseUrl");
    if (appName != null && baseUrl != null) {
      Uri? baseUri;
      try {
        baseUri = Uri.parse(baseUrl);
      } on FormatException catch (e, stack) {
        FlutterUI.log.w("Failed to parse baseUrl url parameter", e, stack);
      }
      String? username = queryParameters.remove("username") ?? queryParameters.remove("userName");
      String? password = queryParameters.remove("password");

      ServerConfig? urlConfig = ServerConfig(
        appName: appName,
        baseUrl: baseUri,
        username: username,
        password: password,
        isDefault: true,
      );

      if (urlConfig.isValid) {
        urlApp = await App.createAppFromConfig(urlConfig);

        await ConfigController().updateCurrentApp(urlApp.id);
        if (ConfigController().currentApp.value != null) {
          String? language = queryParameters.remove("language");
          if (language != null) {
            await ConfigController().updateUserLanguage(
              language == ConfigController().getPlatformLocale() ? null : language,
            );
          }
          String? timeZone = queryParameters.remove("timeZone");
          if (timeZone != null) {
            await ConfigController().updateApplicationTimeZone(timeZone);
          }
        }
      }
    }
    String? mobileOnly = queryParameters.remove("mobileOnly");
    if (mobileOnly != null) {
      IUiService().updateMobileOnly(mobileOnly == "true");
    }
    String? webOnly = queryParameters.remove("webOnly");
    if (webOnly != null) {
      IUiService().updateWebOnly(webOnly == "true");
    }

    return urlApp;
  }
}

late BeamerDelegate routerDelegate;
GlobalKey<NavigatorState>? splashNavigatorKey;

/// Global Bucket to persist the storage between different locations
PageStorageBucket pageStorageBucket = PageStorageBucket();

class FlutterUIState extends State<FlutterUI> with WidgetsBindingObserver {
  static App? urlConfig;

  final RoutesObserver routeObserver = RoutesObserver();

  AppLifecycleState? lastState;

  late ThemeData themeData;
  late ThemeData darkThemeData;

  final ThemeData splashTheme = JVxColors.applyJVxTheme(ThemeData(
    colorScheme: JVxColors.applyJVxColorScheme(ColorScheme.fromSeed(
      seedColor: Colors.blue,
    )),
  ));

  late final StreamSubscription<ConnectivityResult> subscription;

  Future<void>? startupFuture;
  Future<void>? exitFuture;

  /// The last password that the user entered, used for offline switch.
  String? lastPassword;

  @override
  void initState() {
    super.initState();

    routerDelegate = BeamerDelegate(
      initialPath: "/apps",
      setBrowserTabTitle: false,
      navigatorObservers: [routeObserver],
      locationBuilder: BeamerLocationBuilder(
        beamLocations: [
          AppLocation(),
          LoginLocation(),
          MenuLocation(),
          SettingsLocation(),
          WorkScreenLocation(),
        ],
      ),
      transitionDelegate:
          (kIsWeb ? const NoAnimationTransitionDelegate() as TransitionDelegate : const DefaultTransitionDelegate()),
      guards: [
        // Guards /apps by beaming to /menu if an app is active
        BeamGuard(
          pathPatterns: ["/", "/apps"],
          check: (context, location) => ConfigController().currentApp.value == null || exitFuture != null,
          beamToNamed: (origin, target) => "/menu",
        ),
        // Guards everything except /apps and /settings by beaming to /apps if there is no active app
        BeamGuard(
          guardNonMatching: true,
          pathPatterns: ["/", "/apps", "/settings"],
          check: (context, location) => ConfigController().currentApp.value != null && exitFuture == null,
          beamToNamed: (origin, target) => "/apps",
        ),
      ],
    );

    WidgetsBinding.instance.addObserver(this);
    subscription = Connectivity().onConnectivityChanged.listen(didChangeConnectivity);

    // Register callbacks
    ConfigController().disposeImagesCallbacks();
    ConfigController().registerImagesCallback(refresh);

    // Update style to reflect web colors for theme
    // Don't forget to remove them in [dispose]!
    // ignore: invalid_use_of_protected_member
    assert(!IUiService().layoutMode.hasListeners);
    IUiService().layoutMode.addListener(changedTheme);
    ConfigController().themePreference.addListener(changedTheme);
    ConfigController().applicationStyle.addListener(changedTheme);
    IUiService().applicationSettings.addListener(refresh);
    IUiService().i18n().currentLanguage.addListener(refresh);

    // Init default themes (if applicable)
    changedTheme();

    // Init
    if (urlConfig != null) {
      startApp(appId: urlConfig!.id, autostart: true);
    } else {
      List<App> apps = App.getAppsByIDs(AppService().getAppIds());
      AppConfig appConfig = ConfigController().getAppConfig()!;
      bool showAppOverviewWithoutDefault = appConfig.showAppOverviewWithoutDefault!;
      App? defaultApp = apps.firstWhereOrNull((e) {
        return e.isDefault &&
            (e.predefined || ((appConfig.customAppsAllowed ?? false) || (appConfig.forceSingleAppMode ?? false)));
      });
      if (defaultApp == null && apps.length == 1 && !showAppOverviewWithoutDefault) {
        defaultApp = apps.firstOrNull;
      }
      if (defaultApp?.isStartable ?? false) {
        startApp(appId: defaultApp!.id, autostart: true);
      }
    }
  }

  Future<void> startApp({String? appId, bool? autostart}) {
    setState(() {
      exitFuture = null;
      startupFuture = AppService()
          .startApp(appId: appId, autostart: autostart)
          .then((value) => changedTheme())
          .catchError(FlutterUI.createErrorHandler("Failed to send startup"));
    });
    return startupFuture!;
  }

  Future<void> stopApp([bool resetAppName = true]) {
    setState(() {
      startupFuture = null;
      exitFuture = AppService()
          .stopApp(resetAppName)
          .catchError(FlutterUI.createErrorHandler("There was an error while exiting the app"));
    });
    return exitFuture!;
  }

  @override
  Widget build(BuildContext context) {
    List<Locale> supportedLocales = {
      ConfigController().applicationLanguage.value,
      ConfigController().getPlatformLocale(),
      ...ConfigController().supportedLanguages.value,
      "en",
    }.whereNotNull().map((e) => Locale(e)).toList();

    return ValueListenableBuilder<ApplicationParameters?>(
      valueListenable: IUiService().applicationParameters,
      builder: (context, value, _) {
        String title =
            (kIsWeb ? value?.applicationTitleWeb : null) ?? widget.appConfig?.title ?? FlutterUI.packageInfo.appName;
        return MaterialApp.router(
          themeMode: ConfigController().themePreference.value,
          theme: themeData,
          darkTheme: darkThemeData,
          locale: Locale(ConfigController().getLanguage()),
          supportedLocales: supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          routeInformationParser: BeamerParser(),
          routerDelegate: routerDelegate,
          backButtonDispatcher: BeamerBackButtonDispatcher(delegate: routerDelegate),
          title: title,
          builder: _routeBuilder(),
        );
      },
    );
  }

  TransitionBuilder _routeBuilder() {
    return (context, child) {
      Widget futureBuilder = FutureBuilder(
        future: startupFuture,
        builder: (context, startupSnapshot) => FutureBuilder(
          future: exitFuture,
          builder: (context, exitSnapshot) {
            if ([ConnectionState.active, ConnectionState.waiting].contains(startupSnapshot.connectionState) ||
                (startupSnapshot.connectionState == ConnectionState.done && startupSnapshot.hasError)) {
              retrySplash() => startApp();
              splashReturnToApps() {
                IUiService().routeToAppOverview();
                setState(() {
                  startupFuture = null;
                });
              }

              return _buildSplash(
                startupFuture!,
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
              return _buildExitSplash(JVxOverlay(child: child), snapshot: exitSnapshot);
            }

            return JVxOverlay(child: child);
          },
        ),
      );

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
    };
  }

  /// Builds a Navigator with a custom theme to push dialogs in the splash.
  ///
  /// This uses a Navigator instead of full blown MaterialApp to not touch existing routes, see [Navigator.reportsRouteUpdateToEngine].
  /// It also connects the [NavigatorState] to the [future] object, so this can be re-used by multiple futures.
  ///
  /// [AsyncSnapshot] from the parent [FutureBuilder] can't be used, because [Navigator.onGenerateRoute]
  /// is only called once-ish, therefore we have to trigger the update from inside.
  Widget _buildSplash(
    Future future, {
    List<Widget> Function(AsyncSnapshot snapshot)? childrenBuilder,
    required VoidCallback retry,
    required VoidCallback returnToApps,
  }) {
    return Theme(
      data: splashTheme,
      child: Navigator(
        // Update key to force Navigator update, which in turn re-generates the route with the new future.
        key: splashNavigatorKey = GlobalObjectKey<NavigatorState>(future),
        onGenerateRoute: (settings) => MaterialPageRoute(
          settings: settings,
          builder: (context) => FutureBuilder(
            future: future,
            builder: (context, snapshot) => Stack(
              children: [
                Splash(
                  splashBuilder: widget.splashBuilder,
                  snapshot: snapshot,
                  onReturn: returnToApps,
                ),
                ...?childrenBuilder?.call(snapshot),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a widget to show when exiting an app.
  Widget _buildExitSplash(
    Widget child, {
    AsyncSnapshot? snapshot,
  }) {
    return Splash(
      splashBuilder: (context, snapshot) {
        return Stack(
          children: [
            child,
            Theme(
              data: splashTheme,
              child: FutureBuilder(
                  future: Future.delayed(const Duration(milliseconds: 250)),
                  builder: (context, snapshot) {
                    return Stack(
                      children: [
                        ModalBarrier(
                          dismissible: false,
                          color: snapshot.connectionState == ConnectionState.done ? Colors.black54 : null,
                        ),
                        if (snapshot.connectionState == ConnectionState.done)
                          Center(
                            child: Material(
                              color: Colors.transparent,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CupertinoActivityIndicator(color: Colors.white, radius: 18),
                                  const SizedBox(height: 15),
                                  Text(
                                    FlutterUI.translateLocal("Exiting..."),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
            ),
          ],
        );
      },
      snapshot: snapshot,
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
        if (IUiService().clientId.value != null && !ConfigController().offline.value) {
          ICommandService()
              .sendCommand(AliveCommand(reason: "App resumed from paused"))
              .catchError((e, stack) => FlutterUI.logAPI.w("Resume Alive Request failed", e, stack));
        }
      }
    }

    if (state != AppLifecycleState.inactive) {
      lastState = state;
    }
  }

  @override
  void dispose() {
    IApiService().getRepository().stop();
    subscription.cancel();
    WidgetsBinding.instance.removeObserver(this);

    IUiService().i18n().currentLanguage.removeListener(refresh);
    IUiService().layoutMode.removeListener(changedTheme);
    ConfigController().themePreference.removeListener(changedTheme);
    ConfigController().applicationStyle.removeListener(changedTheme);
    IUiService().applicationSettings.removeListener(refresh);

    super.dispose();
  }

  void changedTheme() {
    Map<String, String>? styleMap = ConfigController().applicationStyle.value;

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
