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
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logger/logger.dart';
import 'package:material_color_generator/material_color_generator.dart';
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
import 'model/command/api/startup_command.dart';
import 'model/config/application_parameters.dart';
import 'model/request/api_startup_request.dart';
import 'routing/locations/login_location.dart';
import 'routing/locations/menu_location.dart';
import 'routing/locations/settings_location.dart';
import 'routing/locations/work_screen_location.dart';
import 'service/api/i_api_service.dart';
import 'service/api/impl/default/api_service.dart';
import 'service/api/shared/controller/api_controller.dart';
import 'service/api/shared/repository/offline_api_repository.dart';
import 'service/api/shared/repository/online_api_repository.dart';
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
import 'util/debug/debug_detector.dart';
import 'util/debug/debug_overlay.dart';
import 'util/debug/jvx_debug.dart';
import 'util/extensions/jvx_logger_extensions.dart';
import 'util/extensions/list_extensions.dart';
import 'util/http_overrides.dart';
import 'util/import_handler/import_handler.dart';
import 'util/jvx_colors.dart';
import 'util/loading_handler/loading_progress_handler.dart';
import 'util/parse_util.dart';

/// The base Widget representing the JVx to Flutter bridge.
class FlutterUI extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Determines the supported server version which will be sent in the [ApiStartUpRequest]
  static const String supportedServerVersion = "2.4.0";

  /// Loads assets with packages prefix
  static bool package = true;

  /// Have we ever had a context?
  static bool initiated = false;

  /// General logger
  static final Logger log = Logger(
    level: kDebugMode ? Level.debug : Level.info,
    filter: JVxFilter(),
    printer: JVxPrettyPrinter(
      prefix: "GENERAL",
      printTime: true,
      methodCount: 0,
      errorMethodCount: 30,
    ),
  );

  /// API logger
  static final Logger logAPI = Logger(
    level: Level.info,
    filter: JVxFilter(),
    printer: JVxPrettyPrinter(
      prefix: "API",
      printTime: true,
      methodCount: 0,
      errorMethodCount: 30,
    ),
  );

  /// Command logger
  static final Logger logCommand = Logger(
    level: Level.info,
    filter: JVxFilter(),
    printer: JVxPrettyPrinter(
      prefix: "COMMAND",
      printTime: true,
      methodCount: 0,
      errorMethodCount: 30,
    ),
  );

  /// UI logger
  static final Logger logUI = Logger(
    level: Level.warning,
    filter: JVxFilter(),
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

  /// Builder function for custom login widget
  final Widget Function(BuildContext context, LoginMode mode)? loginBuilder;

  final bool enableDebugOverlay;
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
    this.loginBuilder,
    this.enableDebugOverlay = false,
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
  static String translate(String? pText) {
    return ConfigController().translateText(pText ?? "");
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
    await ICommandService().clear(pFullClear);
    await ILayoutService().clear(pFullClear);
    await IStorageService().clear(pFullClear);
    await IDataService().clear(pFullClear);
    await IUiService().clear(pFullClear);
    await IApiService().clear(pFullClear);
  }

  static void resetPageBucket() {
    pageStorageBucket = PageStorageBucket();
  }

  static start([FlutterUI pAppToRun = const FlutterUI()]) async {
    WidgetsFlutterBinding.ensureInitialized();

    BrowserHttpClientException.verbose = !kReleaseMode;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Service init
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    // Config
    ConfigController configController = ConfigController.create(
      configService: ConfigService.create(sharedPrefs: await SharedPreferences.getInstance()),
      fileManager: await IFileManager.getFileManager(),
    );

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

    if (appConfig.serverConfig!.baseUrl != null) {
      var baseUri = Uri.parse(appConfig.serverConfig!.baseUrl!);
      // If no https on a remote host, you have to use localhost because of secure cookies
      if (kIsWeb && kDebugMode && baseUri.host != "localhost" && !baseUri.isScheme("https")) {
        appConfig = appConfig
            .merge(AppConfig(serverConfig: ServerConfig(baseUrl: baseUri.replace(host: "localhost").toString())));
      }
    }

    await configController.loadConfig(appConfig, devConfig != null);
    services.registerSingleton(configController);

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

    // API
    IApiService apiService = ApiService.create();
    apiService.setController(ApiController());
    services.registerSingleton(apiService);

    // ?baseUrl=http%3A%2F%2Flocalhost%3A8888%2FJVx.mobile%2Fservices%2Fmobile&appName=demo
    String? appName = Uri.base.queryParameters['appName'];
    if (appName != null) {
      await configController.updateAppName(appName);
    }
    if (configController.appName.value != null) {
      String? baseUrl = Uri.base.queryParameters['baseUrl'];
      if (baseUrl != null) {
        await configController.updateBaseUrl(baseUrl);
      }
      String? username = Uri.base.queryParameters['username'];
      if (username != null) {
        await configController.updateUsername(username);
      }
      String? password = Uri.base.queryParameters['password'];
      if (password != null) {
        await configController.updatePassword(password);
      }
      String? language = Uri.base.queryParameters['language'];
      if (language != null) {
        await configController.updateUserLanguage(language == ConfigController().getPlatformLocale() ? null : language);
      }
    }
    String? mobileOnly = Uri.base.queryParameters['mobileOnly'];
    if (mobileOnly != null) {
      uiService.updateMobileOnly(mobileOnly == "true");
    }
    String? webOnly = Uri.base.queryParameters['webOnly'];
    if (webOnly != null) {
      uiService.updateWebOnly(webOnly == "true");
    }

    packageInfo = await PackageInfo.fromPlatform();

    fixUrlStrategy();

    tz.initializeTimeZones();

    if (!kIsWeb) {
      HttpOverrides.global = JVxHttpOverrides();
    }

    IUiService().setAppManager(pAppToRun.appManager);

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // API init
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    var repository = configController.offline.value ? OfflineApiRepository() : OnlineApiRepository();
    IApiService().setRepository(repository);

    runApp(pAppToRun);
  }
}

late BeamerDelegate routerDelegate;
GlobalKey<NavigatorState>? splashNavigatorKey;

/// Global Bucket to persist the storage between different locations
PageStorageBucket pageStorageBucket = PageStorageBucket();

class FlutterUIState extends State<FlutterUI> with WidgetsBindingObserver {
  final RoutesObserver routeObserver = RoutesObserver();

  AppLifecycleState? lastState;

  ThemeData themeData = ThemeData().copyWith(
    colorScheme: ThemeData().colorScheme.copyWith(
          background: Colors.grey.shade50,
        ),
  );

  ThemeData darkThemeData = ThemeData.dark().copyWith(
    colorScheme: ThemeData.dark().colorScheme.copyWith(
          background: Colors.grey.shade50,
        ),
  );

  final ThemeData splashTheme = ThemeData();
  late final StreamSubscription<ConnectivityResult> subscription;

  Future<void>? startupFuture;

  @override
  void initState() {
    super.initState();

    routerDelegate = BeamerDelegate(
      initialPath: "/login",
      setBrowserTabTitle: false,
      navigatorObservers: [routeObserver],
      locationBuilder: BeamerLocationBuilder(
        beamLocations: [
          LoginLocation(),
          MenuLocation(),
          SettingsLocation(),
          WorkScreenLocation(),
        ],
      ),
      transitionDelegate:
          (kIsWeb ? const NoAnimationTransitionDelegate() as TransitionDelegate : const DefaultTransitionDelegate()),
    );

    WidgetsBinding.instance.addObserver(this);
    subscription = Connectivity().onConnectivityChanged.listen(didChangeConnectivity);

    // Register callbacks
    ConfigController().disposeLanguageCallbacks();
    ConfigController().registerLanguageCallback((pLanguage) => setState(() {}));
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

    // Init
    restart();
  }

  void restart({
    String? appName,
    String? username,
    String? password,
  }) {
    setState(() {
      startupFuture = initStartup(
        appName: appName,
        username: username,
        password: password,
      ).catchError(FlutterUI.createErrorHandler("Failed to send startup"));
    });
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
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.none ||
              snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
            FlutterUI.initiated = true;
            return JVxOverlay(child: child);
          }

          return _buildSplash(
            startupFuture!,
            childrenBuilder: (snapshot) => [
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasError)
                _getStartupErrorDialog(context, snapshot),
            ],
          );
        },
      );

      if (kDebugMode) {
        futureBuilder = DebugDetector(
          callback: () {
            widget.appManager?.onDebugTrigger();
            if (widget.enableDebugOverlay) {
              HapticFeedback.vibrate();
              showDialog(
                context: FlutterUI.getCurrentContext() ?? FlutterUI.getSplashContext()!,
                builder: (context) => DebugOverlay(
                  useDialog: true,
                  debugEntries: [
                    const JVxDebug(),
                    ...widget.debugOverlayEntries,
                  ],
                ),
              );
            }
          },
          child: futureBuilder,
        );
      }

      return futureBuilder;
    };
  }

  /// Builds a Navigator with a custom theme to push dialogs in the splash.
  ///
  /// This uses a Navigator instead of full blown MaterialApp to not touch existing routes, see [Navigator.reportsRouteUpdateToEngine].
  /// It also connects the [NavigatorState] to the [future] object, so this can be re-used by multiple futures.
  ///
  /// [AsyncSnapshot] from the parent [FutureBuilder] can't be used, because [Navigator.onGenerateRoute]
  /// is only called once-ish, therefore we have to trigger the update from inside.
  Widget _buildSplash(Future future, {List<Widget> Function(AsyncSnapshot snapshot)? childrenBuilder}) {
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
                ),
                ...?childrenBuilder?.call(snapshot),
              ],
            ),
          ),
        ),
      ),
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
          ICommandService().sendCommand(AliveCommand(reason: "App resumed from paused"));
        }
      }
    }

    if (state != AppLifecycleState.inactive) {
      lastState = state;
    }
  }

  @override
  void dispose() {
    IApiService().getRepository()?.stop();
    subscription.cancel();
    WidgetsBinding.instance.removeObserver(this);

    IUiService().layoutMode.removeListener(changedTheme);
    ConfigController().themePreference.removeListener(changedTheme);
    ConfigController().applicationStyle.removeListener(changedTheme);
    IUiService().applicationSettings.removeListener(refresh);

    super.dispose();
  }

  void changedTheme() {
    Map<String, String> styleMap = ConfigController().applicationStyle.value;

    Color? styleColor = kIsWeb ? ParseUtil.parseHexColor(styleMap['web.topmenu.color']) : null;
    styleColor ??= ParseUtil.parseHexColor(styleMap['theme.color']);

    if (styleColor != null) {
      MaterialColor materialColor = generateMaterialColor(color: styleColor);

      themeData = _createTheme(materialColor, Brightness.light);
      darkThemeData = _createTheme(materialColor, Brightness.dark);
    }
    setState(() {});
  }

  ThemeData _createTheme(MaterialColor materialColor, Brightness selectedBrightness) {
    ColorScheme colorScheme = ColorScheme.fromSwatch(
      primarySwatch: materialColor,
      brightness: selectedBrightness,
    );

    bool isBackgroundLight = ThemeData.estimateBrightnessForColor(colorScheme.background) == Brightness.light;

    if (isBackgroundLight) {
      colorScheme = colorScheme.copyWith(background: Colors.grey.shade50);
    }
    if (colorScheme.onPrimary.computeLuminance() == 0.0) {
      colorScheme = colorScheme.copyWith(onPrimary: JVxColors.LIGHTER_BLACK);
    }
    if (colorScheme.onBackground.computeLuminance() == 0.0) {
      colorScheme = colorScheme.copyWith(onBackground: JVxColors.LIGHTER_BLACK);
    }
    if (colorScheme.onSurface.computeLuminance() == 0.0) {
      colorScheme = colorScheme.copyWith(onSurface: JVxColors.LIGHTER_BLACK);
    }

    // Override tealAccent
    colorScheme = colorScheme.copyWith(
      secondary: colorScheme.primary,
      onSecondary: colorScheme.onPrimary,
      secondaryContainer: colorScheme.primaryContainer,
      onSecondaryContainer: colorScheme.onPrimaryContainer,
      tertiary: colorScheme.primary,
      onTertiary: colorScheme.onPrimary,
      tertiaryContainer: colorScheme.primaryContainer,
      onTertiaryContainer: colorScheme.onPrimaryContainer,
    );

    var themeData = ThemeData.from(colorScheme: colorScheme);

    if (themeData.textTheme.bodyLarge?.color?.computeLuminance() == 0.0) {
      themeData = themeData.copyWith(
        textTheme: themeData.textTheme.apply(
          bodyColor: JVxColors.LIGHTER_BLACK,
          displayColor: JVxColors.LIGHTER_BLACK,
        ),
      );
    }

    if (themeData.primaryTextTheme.bodyLarge?.color?.computeLuminance() == 0.0) {
      themeData = themeData.copyWith(
        primaryTextTheme: themeData.primaryTextTheme.apply(
          bodyColor: JVxColors.LIGHTER_BLACK,
          displayColor: JVxColors.LIGHTER_BLACK,
        ),
      );
    }

    if (themeData.iconTheme.color?.computeLuminance() == 0.0) {
      themeData = themeData.copyWith(
        iconTheme: themeData.iconTheme.copyWith(
          color: JVxColors.LIGHTER_BLACK,
        ),
      );
    }

    if (themeData.primaryIconTheme.color?.computeLuminance() == 0.0) {
      themeData = themeData.copyWith(
        iconTheme: themeData.primaryIconTheme.copyWith(
          color: JVxColors.LIGHTER_BLACK,
        ),
      );
    }

    themeData = themeData.copyWith(
      listTileTheme: themeData.listTileTheme.copyWith(
        // TODO Remove workaround after https://github.com/flutter/flutter/issues/112811
        textColor: isBackgroundLight ? JVxColors.LIGHTER_BLACK : Colors.white,
        iconColor: isBackgroundLight ? JVxColors.LIGHTER_BLACK : Colors.white,
        // textColor: themeData.colorScheme.onBackground,
        // iconColor: themeData.colorScheme.onBackground,
      ),
    );
    return themeData;
  }

  void refresh() {
    setState(() {});
  }

  Future<void> initStartup({
    String? appName,
    String? username,
    String? password,
  }) async {
    changedTheme();

    if (ConfigController().getFileManager().isSatisfied()) {
      // Only try to load if FileManager is available
      ConfigController().reloadSupportedLanguages();
      ConfigController().loadLanguages();
    }

    // (Re-)start repository
    if (IApiService().getRepository() is OnlineApiRepository) {
      if (IApiService().getRepository()?.isStopped() == false) {
        await IApiService().getRepository()?.stop();
      }
    }
    await IApiService().getRepository()?.start();

    if (ConfigController().appName.value == null || ConfigController().baseUrl.value == null) {
      IUiService().routeToSettings(pReplaceRoute: true);
      return;
    }

    if (ConfigController().offline.value) {
      IUiService().routeToMenu(pReplaceRoute: true);
      return;
    }

    await FlutterUI.clearServices(true);

    // Send startup to server
    await ICommandService().sendCommand(StartupCommand(
      reason: "InitApp",
      appName: appName,
      username: username ?? ConfigController().getAppConfig()!.serverConfig!.username,
      password: password ?? ConfigController().getAppConfig()!.serverConfig!.password,
    ));
  }

  Widget _getStartupErrorDialog(BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
          title: Text(errorView?.errorCommand.title?.isNotEmpty ?? false
              ? errorView!.errorCommand.title!
              : FlutterUI.translate("Error")),
          content: Text(
            errorView?.errorCommand.message ?? FlutterUI.translate(IUiService.getErrorMessage(snapshot.error!)),
          ),
          actions: [
            TextButton(
              onPressed: () => restart(),
              child: Text(
                FlutterUI.translate("Retry"),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                IUiService().routeToSettings(pReplaceRoute: true);
                setState(() {
                  startupFuture = null;
                });
              },
              child: Text(
                FlutterUI.translate("Go to Settings"),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

T? cast<T>(x) => x is T ? x : null;

class RoutesObserver extends NavigatorObserver {
  final List<Route> knownRoutes = [];

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    knownRoutes.remove(oldRoute);
    if (newRoute != null) {
      knownRoutes.add(newRoute);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    knownRoutes.remove(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    knownRoutes.remove(route);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    knownRoutes.add(route);
  }
}
