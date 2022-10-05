import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logger/logger.dart';
import 'package:material_color_generator/material_color_generator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';

import 'config/app_config.dart';
import 'custom/app_manager.dart';
import 'src/mask/jvx_overlay.dart';
import 'src/mask/splash/splash.dart';
import 'src/model/command/api/startup_command.dart';
import 'src/model/response/device_status_response.dart';
import 'src/routing/locations/login_location.dart';
import 'src/routing/locations/menu_location.dart';
import 'src/routing/locations/settings_location.dart';
import 'src/routing/locations/work_screen_location.dart';
import 'src/service/api/i_api_service.dart';
import 'src/service/api/impl/default/api_service.dart';
import 'src/service/api/shared/controller/api_controller.dart';
import 'src/service/api/shared/repository/offline_api_repository.dart';
import 'src/service/api/shared/repository/online_api_repository.dart';
import 'src/service/command/i_command_service.dart';
import 'src/service/command/impl/command_service.dart';
import 'src/service/config/i_config_service.dart';
import 'src/service/config/impl/config_service.dart';
import 'src/service/data/i_data_service.dart';
import 'src/service/data/impl/data_service.dart';
import 'src/service/file/file_manager.dart';
import 'src/service/layout/i_layout_service.dart';
import 'src/service/layout/impl/isolate/isolate_layout_service.dart';
import 'src/service/layout/impl/layout_service.dart';
import 'src/service/service.dart';
import 'src/service/storage/i_storage_service.dart';
import 'src/service/storage/impl/default/storage_service.dart';
import 'src/service/ui/i_ui_service.dart';
import 'src/service/ui/impl/ui_service.dart';
import 'src/util/config_util.dart';
import 'src/util/loading_handler/loading_progress_handler.dart';
import 'util/constants/i_color.dart';
import 'util/parse_util.dart';

/// The base Widget representing the JVx to Flutter bridge.
class FlutterJVx extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Loads assets with packages prefix
  static bool package = true;

  static final Logger log = Logger(
    level: Level.info,
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 30,
    ),
  );

  /// The initial application configuration
  final AppConfig? appConfig;

  /// The application manager of this app.
  final AppManager? appManager;

  /// Builder function for custom loading widget
  final Widget Function(BuildContext context)? loadingBuilder;

  static late PackageInfo packageInfo;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  const FlutterJVx({
    Key? key,
    this.appConfig,
    this.appManager,
    this.loadingBuilder,
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  @override
  FlutterJVxState createState() => FlutterJVxState();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Gets the [FlutterJVx] widget.
  static FlutterJVx? of(BuildContext context) => context.findAncestorWidgetOfExactType<FlutterJVx>();

  /// Translates any text through the translation files loaded by the application.
  static String translate(String? pText) {
    return IConfigService().translateText(pText ?? "");
  }

  static BuildContext? getCurrentContext() {
    return routerDelegate.navigatorKey.currentContext;
  }

  static start([FlutterJVx pAppToRun = const FlutterJVx()]) async {
    WidgetsFlutterBinding.ensureInitialized();

    BrowserHttpClientException.verbose = !kReleaseMode;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Service init
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    // Config
    IConfigService configService = ConfigService(
      sharedPrefs: await SharedPreferences.getInstance(),
      fileManager: await IFileManager.getFileManager(),
    );
    services.registerSingleton(configService);

    // Layout
    ILayoutService layoutService = kIsWeb ? LayoutService() : await IsolateLayoutService.create();
    services.registerSingleton(layoutService);

    // Storage
    IStorageService storageService = StorageService();
    services.registerSingleton(storageService);

    // Data
    IDataService dataService = DataService();
    services.registerSingleton(dataService);

    // Command
    ICommandService commandService = CommandService();
    services.registerSingleton(commandService);
    (commandService as CommandService).progressHandler.add(LoadingProgressHandler());

    // UI
    IUiService uiService = UiService();
    services.registerSingleton(uiService);

    // API
    IApiService apiService = ApiService();
    apiService.setController(ApiController());
    services.registerSingleton(apiService);

    // ?baseUrl=http%3A%2F%2Flocalhost%3A8888%2FJVx.mobile%2Fservices%2Fmobile&appName=demo
    String? appName = Uri.base.queryParameters["appName"];
    if (appName != null) {
      await configService.setAppName(appName);
    }
    String? baseUrl = Uri.base.queryParameters["baseUrl"];
    if (baseUrl != null) {
      await configService.setBaseUrl(baseUrl);
    }
    String? username = Uri.base.queryParameters["username"];
    if (username != null) {
      await configService.setUsername(username);
    }
    String? password = Uri.base.queryParameters["password"];
    if (password != null) {
      await configService.setUsername(password);
    }
    String? language = Uri.base.queryParameters["language"];
    if (language != null) {
      await configService.setUserLanguage(language == IConfigService.getPlatformLocale() ? null : language);
    }
    String? mobileOnly = Uri.base.queryParameters["mobileOnly"];
    if (mobileOnly != null) {
      await configService.setMobileOnly(mobileOnly == "true");
    }
    String? webOnly = Uri.base.queryParameters["webOnly"];
    if (webOnly != null) {
      await configService.setWebOnly(webOnly == "true");
    }

    packageInfo = await PackageInfo.fromPlatform();

    runApp(pAppToRun);
  }
}

late BeamerDelegate routerDelegate;

class FlutterJVxState extends State<FlutterJVx> {
  /// Gets the [FlutterJVxState] widget.
  static FlutterJVxState? of(BuildContext context) => context.findAncestorStateOfType();

  ThemeData themeData = ThemeData(
    backgroundColor: Colors.grey.shade50,
  );

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

    initAppFuture = initApp().catchError(createErrorHandler("Failed to initialize")).then((value) {
      //Activate second future
      startupFuture = doStartup().catchError(createErrorHandler("Failed to send startup"));
    });
  }

  @override
  void dispose() {
    IApiService().getRepository()?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: themeData,
      routeInformationParser: BeamerParser(),
      routerDelegate: routerDelegate,
      backButtonDispatcher: BeamerBackButtonDispatcher(delegate: routerDelegate),
      builder: (context, child) {
        return FutureBuilder(
          future: initAppFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasError && snapshot.connectionState == ConnectionState.done) {
              return FutureBuilder(
                future: startupFuture,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.none ||
                      !snapshot.hasError && snapshot.connectionState == ConnectionState.done) {
                    return JVxOverlay(child: child ?? const SizedBox.shrink());
                  }

                  return Stack(children: [
                    Splash(loadingBuilder: widget.loadingBuilder, snapshot: snapshot),
                    if (snapshot.hasError) _getStartupErrorDialog(context, snapshot),
                  ]);
                },
              );
            }

            return Stack(children: [
              Splash(loadingBuilder: widget.loadingBuilder, snapshot: snapshot),
              if (snapshot.hasError) _getFatalErrorDialog(context, snapshot),
            ]);
          },
        );
      },
      title: widget.appConfig?.title ?? FlutterJVx.packageInfo.appName,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }

  void changeStyle(Map<String, String> styleMap) {
    Color? styleColor = IConfigService().getLayoutMode().value != LayoutMode.Mini
        ? ParseUtil.parseHexColor(styleMap['web.topmenu.color'])
        : null;
    styleColor ??= ParseUtil.parseHexColor(styleMap['theme.color']);
    if (styleColor != null) {
      MaterialColor materialColor = generateMaterialColor(color: styleColor);

      ColorScheme colorScheme = ColorScheme.fromSwatch(
        primarySwatch: materialColor,
        backgroundColor: Colors.grey.shade50,
      );

      if (colorScheme.onPrimary.computeLuminance() == 0.0) {
        colorScheme = colorScheme.copyWith(onPrimary: IColorConstants.JVX_LIGHTER_BLACK);
      }
      if (colorScheme.onBackground.computeLuminance() == 0.0) {
        colorScheme = colorScheme.copyWith(onBackground: IColorConstants.JVX_LIGHTER_BLACK);
      }
      if (colorScheme.onSurface.computeLuminance() == 0.0) {
        colorScheme = colorScheme.copyWith(onSurface: IColorConstants.JVX_LIGHTER_BLACK);
      }

      themeData = ThemeData.from(colorScheme: colorScheme);

      bool backgroundColorIsLight = ThemeData.estimateBrightnessForColor(themeData.backgroundColor) == Brightness.light;
      themeData = themeData.copyWith(
        listTileTheme: themeData.listTileTheme.copyWith(
          //TODO Remove workaround after https://github.com/flutter/flutter/issues/112811
          textColor: backgroundColorIsLight ? IColorConstants.JVX_LIGHTER_BLACK : Colors.white,
          iconColor: backgroundColorIsLight ? IColorConstants.JVX_LIGHTER_BLACK : Colors.white,
          // textColor: themeData.colorScheme.onBackground,
          // iconColor: themeData.colorScheme.onBackground,
        ),
      );
      setState(() {});
    }
  }

  void changeLanguage(String pLanguage) {
    setState(() {});
  }

  void changedImages() {
    setState(() {});
  }

  Function(Object error, StackTrace stackTrace) createErrorHandler(String pMessage) {
    return (error, stackTrace) {
      FlutterJVx.log.e(pMessage, error, stackTrace);
      throw error;
    };
  }

  Future<void> initApp() async {
    HttpOverrides.global = MyHttpOverrides();

    IConfigService configService = IConfigService();
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
        FlutterJVx.log.i("Found dev config, overriding values");
      }
    }

    AppConfig appConfig =
        const AppConfig.empty().merge(widget.appConfig).merge(await ConfigUtil.readAppConfig()).merge(devConfig);

    await (configService as ConfigService).setAppConfig(appConfig, devConfig != null);

    if (appConfig.serverConfig!.baseUrl != null) {
      var baseUri = Uri.parse(appConfig.serverConfig!.baseUrl!);
      //If no https on a remote host, you have to use localhost because of secure cookies
      if (kIsWeb && kDebugMode && baseUri.host != "localhost" && !baseUri.isScheme("https")) {
        await configService.setBaseUrl(baseUri.replace(host: "localhost").toString());
      }
    }

    //Register callbacks
    configService.disposeStyleCallbacks();
    configService.registerStyleCallback(changeStyle);
    configService.disposeLanguageCallbacks();
    configService.registerLanguageCallback(changeLanguage);
    configService.disposeImagesCallbacks();
    configService.registerImagesCallback(changedImages);

    configService.getLayoutMode().addListener(() {
      changeStyle(IConfigService().getAppStyle());
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

    configService.setPhoneSize(!kIsWeb ? MediaQueryData.fromWindow(WidgetsBinding.instance.window).size : null);
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // API init
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    var repository = configService.isOffline() ? OfflineApiRepository() : OnlineApiRepository();
    await repository.start();
    apiService.setRepository(repository);
  }

  Future<void> doStartup() async {
    IConfigService configService = IConfigService();
    ICommandService commandService = ICommandService();
    IUiService uiService = IUiService();

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
      username: configService.getAppConfig()!.serverConfig!.username,
      password: configService.getAppConfig()!.serverConfig!.password,
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
              : FlutterJVx.translate("Error")),
          content: Text(errorView?.errorCommand.message ?? IUiService.getErrorMessage(snapshot.error!)),
          actions: [
            TextButton(
              onPressed: () {
                routerDelegate.setNewRoutePath(const RouteInformation(location: "/settings"));
                startupFuture = null;
                setState(() {});
              },
              child: Text(
                FlutterJVx.translate("Go to Settings"),
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
