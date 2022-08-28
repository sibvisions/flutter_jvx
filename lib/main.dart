import 'dart:developer';
import 'dart:io';

import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/app_config.dart';
import 'custom/app_manager.dart';
import 'src/routing/locations/login_location.dart';
import 'src/routing/locations/menu_location.dart';
import 'src/routing/locations/settings_location.dart';
import 'src/routing/locations/splash_location.dart';
import 'src/routing/locations/work_screen_location.dart';
import 'src/service/api/i_api_service.dart';
import 'src/service/api/impl/default/api_service.dart';
import 'src/service/api/shared/controller/api_controller.dart';
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
import 'src/service/storage/impl/isolate/isolate_storage_service.dart';
import 'src/service/ui/i_ui_service.dart';
import 'src/service/ui/impl/ui_service.dart';
import 'src/util/loading_handler/loading_overlay.dart';
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

    if (configService.getAppName() != null && configService.getVersion() != null) {
      // Only load if name and version is available for FileManager
      configService.reloadSupportedLanguages();
    }

    // Layout
    ILayoutService layoutService = kIsWeb ? LayoutService() : await IsolateLayoutService.create();
    services.registerSingleton(layoutService);

    // Storage
    IStorageService storageService = kIsWeb ? StorageService() : await IsolateStorageService.create();
    services.registerSingleton(storageService);

    // Data
    IDataService dataService = DataService();
    services.registerSingleton(dataService);

    // Command
    ICommandService commandService = CommandService();
    services.registerSingleton(commandService);

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

  @override
  void initState() {
    super.initState();

    routerDelegate = BeamerDelegate(
      initialPath: "/splash",
      locationBuilder: BeamerLocationBuilder(
        beamLocations: [
          SplashLocation(
            appConfig: widget.appConfig,
            appManager: widget.appManager,
            loadingBuilder: widget.loadingBuilder,
            styleCallbacks: [changeStyle],
            languageCallbacks: [changeLanguage],
            imagesCallbacks: [changedImages],
          ),
          LoginLocation(),
          MenuLocation(),
          SettingsLocation(),
          WorkScreenLocation(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //_routerDelegate.setNewRoutePath(const RouteInformation(location: "/splash"));

    return MaterialApp.router(
      theme: themeData,
      routeInformationParser: BeamerParser(),
      routerDelegate: routerDelegate,
      backButtonDispatcher: BeamerBackButtonDispatcher(delegate: routerDelegate),
      builder: (context, child) => LoadingOverlay(child: child),
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
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    var client = super.createHttpClient(context);
    if (!kIsWeb) {
      // Needed to avoid CORS issues
      // TODO find way to not do this
      client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    }
    return client;
  }
}
