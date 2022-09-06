import 'dart:async';
import 'dart:developer';

import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';

import 'config/app_config.dart';
import 'custom/app_manager.dart';
import 'src/mask/splash/splash_widget.dart';
import 'src/model/command/api/set_api_config_command.dart';
import 'src/model/command/api/startup_command.dart';
import 'src/model/config/api/api_config.dart';
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
import 'src/util/loading_handler/loading_overlay.dart';
import 'src/util/loading_handler/loading_progress_handler.dart';
import 'util/logging/flutter_logger.dart';
import 'util/parse_util.dart';

export 'package:beamer/beamer.dart';

void main() async {
  FlutterJVx.package = false;
  await FlutterJVx.start();
}

class FlutterJVx extends StatefulWidget {
  //Loads assets with packages prefix
  static bool package = true;

  final AppConfig? appConfig;
  final AppManager? appManager;

  /// Builder function for custom loading widget
  final Widget Function(BuildContext context)? loadingBuilder;

  const FlutterJVx({
    Key? key,
    this.appConfig,
    this.appManager,
    this.loadingBuilder,
  }) : super(key: key);

  @override
  FlutterJVxState createState() => FlutterJVxState();

  static FlutterJVxState? of(BuildContext context) => context.findAncestorStateOfType<FlutterJVxState>();

  static start([FlutterJVx pAppToRun = const FlutterJVx()]) async {
    WidgetsFlutterBinding.ensureInitialized();

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
    await apiService.setController(ApiController());
    services.registerSingleton(apiService);

    runApp(pAppToRun);
  }
}

late BeamerDelegate routerDelegate;

class FlutterJVxState extends State<FlutterJVx> {
  ThemeData themeData = ThemeData(
    backgroundColor: Colors.grey.shade50,
  );

  late Future<void> initAppFuture;
  Future<void>? startupFuture;

  @override
  void initState() {
    super.initState();

    routerDelegate = BeamerDelegate(
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

    initAppFuture = initApp().onError(createErrorHandler("Failed to initialize")).then((value) {
      //Activate second future
      startupFuture = doStartup().onError(createErrorHandler("Failed to send startup"));
    });
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
                    return LoadingOverlay(child: child);
                  }

                  return Stack(children: [
                    SplashWidget(
                      loadingBuilder: widget.loadingBuilder,
                    ),
                    if (snapshot.hasError) _getStartupErrorDialog(context, snapshot),
                  ]);
                },
              );
            }

            return Stack(children: [
              SplashWidget(
                loadingBuilder: widget.loadingBuilder,
              ),
              if (snapshot.hasError) _getFatalErrorDialog(context, snapshot),
            ]);
          },
        );
      },
      title: widget.appConfig?.title ?? "JVx Mobile",
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales:
          services<IConfigService>().getSupportedLanguages().map((e) => Locale.fromSubtags(languageCode: e)),
      locale: Locale.fromSubtags(languageCode: services<IConfigService>().getLanguage()),
    );
  }

  void changeStyle(Map<String, String> styleMap) {
    Color? styleColor = ParseUtil.parseHexColor(styleMap['theme.color']);
    if (styleColor != null) {
      themeData = ThemeData.from(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: ParseUtil.getMaterialColor(styleColor),
          backgroundColor: Colors.grey.shade50,
        ),
      );
    }
    setState(() {});
  }

  void changeLanguage(String pLanguage) {
    log("setLanguage");
    setState(() {});
  }

  void changedImages() {
    log("changedImages");
    setState(() {});
  }

  Function(Object error, StackTrace stackTrace) createErrorHandler(String pMessage) {
    return (error, stackTrace) {
      LOGGER.logE(
        pType: LogType.GENERAL,
        pMessage: pMessage,
        pError: error,
        pStacktrace: stackTrace,
      );
      throw error;
    };
  }

  Future<void> initApp() async {
    HttpOverrides.global = MyHttpOverrides();

    IConfigService configService = services<IConfigService>();
    IUiService uiService = services<IUiService>();
    IApiService apiService = services<IApiService>();

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Load config
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    uiService.setAppManager(widget.appManager);

    // Load config files
    AppConfig? devConfig;
    if (!kReleaseMode) {
      devConfig = await ConfigUtil.readDevConfig();
      if (devConfig != null) {
        LOGGER.logI(pType: LogType.CONFIG, pMessage: "Found dev config, overriding values");
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

    //Init saved app style
    var appStyle = configService.getAppStyle();
    if (appStyle.isNotEmpty) {
      await configService.setAppStyle(appStyle);
    }

    if (configService.getAppName() != null && configService.getVersion() != null) {
      // Only load if name and version is available for FileManager
      configService.reloadSupportedLanguages();
      configService.loadLanguages();
    }

    configService.setPhoneSize(!kIsWeb ? MediaQueryData.fromWindow(WidgetsBinding.instance.window).size : null);

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // API init
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    var repository = configService.isOffline() ? OfflineApiRepository() : OnlineApiRepository();
    await repository.start();
    await apiService.setRepository(repository);
  }

  Future<void> doStartup() async {
    IConfigService configService = services<IConfigService>();
    ICommandService commandService = services<ICommandService>();
    IUiService uiService = services<IUiService>();

    if (configService.getAppName() == null || configService.getBaseUrl() == null) {
      uiService.routeToSettings(pReplaceRoute: true);
      return;
    }

    if (configService.isOffline()) {
      uiService.routeToMenu(pReplaceRoute: true);
      return;
    }

    await commandService.sendCommand(SetApiConfigCommand(
      apiConfig: ApiConfig(serverConfig: configService.getServerConfig()),
      reason: "Startup Api Config",
    ));

    // Send startup to server
    await commandService.sendCommand(StartupCommand(
      reason: "InitApp",
      username: configService.getAppConfig()!.serverConfig!.username,
      password: configService.getAppConfig()!.serverConfig!.password,
    ));
  }

  Widget _getStartupErrorDialog(BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        backgroundColor: Theme.of(context).cardColor.withAlpha(255),
        title: Text(services<IConfigService>().translateText("Error")),
        content: Text(IUiService.getErrorMessage(snapshot.error!)),
        actions: [
          TextButton(
            onPressed: () {
              routerDelegate.setNewRoutePath(const RouteInformation(location: "/settings"));
              startupFuture = null;
              setState(() {});
            },
            child: Text(
              services<IConfigService>().translateText("Go to Settings"),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getFatalErrorDialog(BuildContext context, AsyncSnapshot snapshot) {
    return WillPopScope(
      onWillPop: () async {
        await SystemNavigator.pop();
        return false;
      },
      child: AlertDialog(
        backgroundColor: Theme.of(context).cardColor.withAlpha(255),
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
