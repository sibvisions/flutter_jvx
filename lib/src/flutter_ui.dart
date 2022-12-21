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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:logger/logger.dart';
import 'package:material_color_generator/material_color_generator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';

import 'config/app_config.dart';
import 'custom/app_manager.dart';
import 'exceptions/error_view_exception.dart';
import 'mask/debug_overlay.dart';
import 'mask/jvx_overlay.dart';
import 'mask/splash/splash.dart';
import 'model/command/api/alive_command.dart';
import 'model/command/api/login_command.dart';
import 'model/command/api/startup_command.dart';
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
import 'util/extensions/jvx_logger_extensions.dart';
import 'util/extensions/list_extensions.dart';
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
  static const String supportedServerVersion = "2.1.0";

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
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  @override
  FlutterUIState createState() => FlutterUIState();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Gets the [FlutterUI] widget.
  static FlutterUI? of(BuildContext context) => context.findAncestorWidgetOfExactType<FlutterUI>();

  /// Translates any text through the translation files loaded by the application.
  static String translate(String? pText) {
    return ConfigService().translateText(pText ?? "");
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

  static void clearServices(bool pFullClear) {
    ILayoutService().clear();
    IStorageService().clear(pFullClear);
    IDataService().clear();
    IUiService().clear();
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
    ConfigService configService = ConfigService.create(
      sharedPrefs: await SharedPreferences.getInstance(),
      fileManager: await IFileManager.getFileManager(),
    );
    services.registerSingleton(configService);

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
      await configService.setAppName(appName);
    }
    if (configService.getAppName() != null) {
      String? baseUrl = Uri.base.queryParameters['baseUrl'];
      if (baseUrl != null) {
        await configService.setBaseUrl(baseUrl);
      }
      String? username = Uri.base.queryParameters['username'];
      if (username != null) {
        await configService.setUsername(username);
      }
      String? password = Uri.base.queryParameters['password'];
      if (password != null) {
        await configService.setPassword(password);
      }
      String? language = Uri.base.queryParameters['language'];
      if (language != null) {
        await configService.setUserLanguage(language == ConfigService().getPlatformLocale() ? null : language);
      }
    }
    String? mobileOnly = Uri.base.queryParameters['mobileOnly'];
    if (mobileOnly != null) {
      configService.setMobileOnly(mobileOnly == "true");
    }
    String? webOnly = Uri.base.queryParameters['webOnly'];
    if (webOnly != null) {
      configService.setWebOnly(webOnly == "true");
    }

    packageInfo = await PackageInfo.fromPlatform();

    fixUrlStrategy();

    await initTimeZones();

    runApp(pAppToRun);
  }
}

late BeamerDelegate routerDelegate;
GlobalKey<NavigatorState>? splashNavigatorKey;

/// Global Bucket to persist the storage between different locations
PageStorageBucket pageStorageBucket = PageStorageBucket();

class FlutterUIState extends State<FlutterUI> with WidgetsBindingObserver {
  AppLifecycleState? lastState;

  /// Gets the [FlutterUIState] widget.
  static FlutterUIState? of(BuildContext? context) => context?.findAncestorStateOfType();

  ThemeData themeData = ThemeData(
    backgroundColor: Colors.grey.shade50,
  );

  final ThemeData splashTheme = ThemeData();

  late Future<void> initAppFuture;
  Future<void>? startupFuture;

  @override
  void initState() {
    super.initState();

    routerDelegate = BeamerDelegate(
      initialPath: "/login",
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

    initAppFuture = initApp().catchError(createErrorHandler("Failed to initialize")).then((value) {
      // Activate second future
      restart();
    });
  }

  void restart({
    String? appName,
    String? username,
    String? password,
  }) {
    setState(() {
      startupFuture = doStartup(
        appName: appName,
        username: username,
        password: password,
      ).catchError(createErrorHandler("Failed to send startup"));
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Locale> supportedLocales = {
      ConfigService().getApplicationLanguage(),
      ConfigService().getPlatformLocale(),
      ...ConfigService().getSupportedLanguages(),
      "en",
    }.whereNotNull().map((e) => Locale(e)).toList();

    return MaterialApp.router(
      theme: themeData,
      locale: Locale(ConfigService().getLanguage()),
      supportedLocales: supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routeInformationParser: BeamerParser(),
      routerDelegate: routerDelegate,
      backButtonDispatcher: BeamerBackButtonDispatcher(delegate: routerDelegate),
      title: widget.appConfig?.title ?? FlutterUI.packageInfo.appName,
      builder: (context, child) {
        Widget futureBuilder = FutureBuilder(
          future: initAppFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasError && snapshot.connectionState == ConnectionState.done) {
              return FutureBuilder(
                future: startupFuture,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.none ||
                      snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
                    FlutterUI.initiated = true;
                    return JVxOverlay(child: child ?? const SizedBox.shrink());
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
            }

            return _buildSplash(
              initAppFuture,
              childrenBuilder: (snapshot) => [
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasError)
                  _getFatalErrorDialog(context, snapshot),
              ],
            );
          },
        );

        if (kDebugMode) {
          futureBuilder = DebugOverlay(
            callback: () {
              widget.appManager?.onDebugTrigger();
            },
            child: futureBuilder,
          );
        }

        return futureBuilder;
      },
    );
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

  @override
  void didChangePlatformBrightness() {
    changedTheme();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (lastState != null) {
      if (lastState == AppLifecycleState.paused && state == AppLifecycleState.resumed) {
        // App was resumed from a paused state (Permission overlay is not paused)
        if (ConfigService().getClientId() != null && !ConfigService().isOffline()) {
          ICommandService().sendCommand(AliveCommand(reason: "App resumed from paused"));
        }
      }
    }

    lastState = state;
  }

  @override
  void dispose() {
    IApiService().getRepository()?.stop();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void changedTheme() {
    Map<String, String> styleMap = ConfigService().getAppStyle();

    Color? styleColor = kIsWeb ? ParseUtil.parseHexColor(styleMap['web.topmenu.color']) : null;
    styleColor ??= ParseUtil.parseHexColor(styleMap['theme.color']);

    if (styleColor != null) {
      MaterialColor materialColor = generateMaterialColor(color: styleColor);

      Brightness selectedBrightness;
      switch (ConfigService().getThemePreference()) {
        case ThemeMode.light:
          selectedBrightness = Brightness.light;
          break;
        case ThemeMode.dark:
          selectedBrightness = Brightness.dark;
          break;
        case ThemeMode.system:
        default:
          selectedBrightness = MediaQueryData.fromWindow(WidgetsBinding.instance.window).platformBrightness;
      }

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

      themeData = ThemeData.from(colorScheme: colorScheme);

      if (themeData.textTheme.bodyText1?.color?.computeLuminance() == 0.0) {
        themeData = themeData.copyWith(
          textTheme: themeData.textTheme.apply(
            bodyColor: JVxColors.LIGHTER_BLACK,
            displayColor: JVxColors.LIGHTER_BLACK,
          ),
        );
      }

      if (themeData.primaryTextTheme.bodyText1?.color?.computeLuminance() == 0.0) {
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
        // Override for dark mode
        toggleableActiveColor: themeData.colorScheme.primary,
        listTileTheme: themeData.listTileTheme.copyWith(
          // TODO Remove workaround after https://github.com/flutter/flutter/issues/112811
          textColor: isBackgroundLight ? JVxColors.LIGHTER_BLACK : Colors.white,
          iconColor: isBackgroundLight ? JVxColors.LIGHTER_BLACK : Colors.white,
          // textColor: themeData.colorScheme.onBackground,
          // iconColor: themeData.colorScheme.onBackground,
        ),
      );
    }
    setState(() {});
  }

  void changeLanguage(String pLanguage) {
    setState(() {});
  }

  void changedImages() {
    setState(() {});
  }

  Function(Object error, StackTrace stackTrace) createErrorHandler(String pMessage) {
    return (error, stackTrace) {
      FlutterUI.log.e(pMessage, error, stackTrace);
      throw error;
    };
  }

  Future<void> initApp() async {
    HttpOverrides.global = MyHttpOverrides();

    ConfigService configService = ConfigService();
    IUiService uiService = IUiService();
    IApiService apiService = IApiService();

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Load config
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    uiService.setAppManager(widget.appManager);

    // Load config files
    AppConfig? devConfig;
    if (!kReleaseMode) {
      devConfig = await ConfigUtil.readDevConfig();
      if (devConfig != null) {
        FlutterUI.log.i("Found dev config, overriding values");
      }
    }

    AppConfig appConfig =
        const AppConfig.empty().merge(widget.appConfig).merge(await ConfigUtil.readAppConfig()).merge(devConfig);

    await configService.setAppConfig(appConfig, devConfig != null);

    if (appConfig.serverConfig!.baseUrl != null) {
      var baseUri = Uri.parse(appConfig.serverConfig!.baseUrl!);
      //If no https on a remote host, you have to use localhost because of secure cookies
      if (kIsWeb && kDebugMode && baseUri.host != "localhost" && !baseUri.isScheme("https")) {
        await configService.setBaseUrl(baseUri.replace(host: "localhost").toString());
      }
    }

    //Register callbacks
    configService.disposeStyleCallbacks();
    configService.registerStyleCallback(changedTheme);
    configService.disposeLanguageCallbacks();
    configService.registerLanguageCallback(changeLanguage);
    configService.disposeImagesCallbacks();
    configService.registerImagesCallback(changedImages);

    //Update style to reflect web colors for theme
    configService.getLayoutModeNotifier().addListener(() {
      changedTheme();
      setState(() {});
    });

    //Init saved app style
    var appStyle = configService.getAppStyle();
    if (appStyle.isNotEmpty) {
      await configService.setAppStyle(appStyle);
    }

    if (configService.getFileManager().isSatisfied()) {
      // Only try to load if FileManager is available
      configService.reloadSupportedLanguages();
      configService.loadLanguages();
    }

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // API init
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    var repository = configService.isOffline() ? OfflineApiRepository() : OnlineApiRepository();
    await repository.start();
    apiService.setRepository(repository);
  }

  Future<void> doStartup({
    String? appName,
    String? username,
    String? password,
  }) async {
    ConfigService configService = ConfigService();
    ICommandService commandService = ICommandService();
    IUiService uiService = IUiService();

    // Update native timezone
    configService.setLocalTimeZone(await FlutterNativeTimezone.getLocalTimezone());

    if (configService.getAppName() == null || configService.getBaseUrl() == null) {
      uiService.routeToSettings(pReplaceRoute: true);
      return;
    }

    if (configService.isOffline()) {
      uiService.routeToMenu(pReplaceRoute: true);
      return;
    }

    // Send startup to server
    await commandService.sendCommand(StartupCommand(
      reason: "InitApp",
      appName: appName,
      username: username ?? configService.getAppConfig()!.serverConfig!.username,
      password: password ?? configService.getAppConfig()!.serverConfig!.password,
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

  Widget _getFatalErrorDialog(BuildContext context, AsyncSnapshot snapshot) {
    return WillPopScope(
      onWillPop: () async {
        await SystemNavigator.pop();
        return false;
      },
      child: AlertDialog(
        title: const Text("FATAL ERROR"),
        content: Text(snapshot.error.toString()),
        actions: [
          if (!kIsWeb)
            TextButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              child: const Text(
                "Exit App",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    var client = super.createHttpClient(context);
    if (!kIsWeb) {
      // TODO find way to not do this
      client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    }
    return client;
  }
}
