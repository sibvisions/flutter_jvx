import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'data/config/config_generator.dart';
import 'main.dart';
import 'src/model/command/api/startup_command.dart';
import 'src/model/config/api/api_config.dart';
import 'src/model/config/api/endpoint_config.dart';
import 'src/model/config/api/url_config.dart';
import 'src/model/config/config_file/app_config.dart';
import 'src/model/config/config_file/last_run_config.dart';
import 'src/model/custom/custom_screen_manager.dart';
import 'src/service/api/i_api_service.dart';
import 'src/service/api/impl/isolate/isolate_api.dart';
import 'src/service/api/shared/controller/api_controller.dart';
import 'src/service/api/shared/i_controller.dart';
import 'src/service/api/shared/i_repository.dart';
import 'src/service/api/shared/repository/online_api_repository.dart';
import 'src/service/command/i_command_service.dart';
import 'src/service/command/impl/command_service.dart';
import 'src/service/config/i_config_service.dart';
import 'src/service/config/impl/config_service.dart';
import 'src/service/data/i_data_service.dart';
import 'src/service/data/impl/data_service.dart';
import 'src/service/layout/i_layout_service.dart';
import 'src/service/layout/impl/isolate/isolate_layout_service.dart';
import 'src/service/service.dart';
import 'src/service/storage/i_storage_service.dart';
import 'src/service/storage/impl/isolate/isolate_storage_service.dart';
import 'src/service/ui/i_ui_service.dart';
import 'src/service/ui/impl/ui_service.dart';
import 'util/file/file_manager_mobile.dart';
import 'util/loading_handler/default_loading_progress_handler.dart';
import 'util/logging/flutter_logger.dart';

Future<bool> initApp({
  CustomScreenManager? pCustomManager,
  required BuildContext initContext,
  List<Function>? languageCallbacks,
  List<Function>? styleCallbacks,
}) async {
  // Needed to avoid CORS issues
  // ToDo find way to not do this
  HttpOverrides.global = MyHttpOverrides();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Init values
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // If not called will throw error when trying to access any files
  WidgetsFlutterBinding.ensureInitialized();

  // Init values, should be possible to provide to initApp
  String appName = "demo";
  String langCode = "en";
  String? auth;
  String? userName;
  String? password;

  FileMangerMobile fileMangerMobile = await FileMangerMobile.create();
  fileMangerMobile.setAppName(pName: appName);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Load config files
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // Load Dev config
  UrlConfig urlConfigServer = UrlConfig.empty();
  AppConfig? appConfig;
  try {
    String rawConfig = await rootBundle.loadString('assets/config/app.conf.json');
    appConfig = AppConfig.fromJson(json: jsonDecode(rawConfig));

    userName = appConfig.startupParameters?.username;
    password = appConfig.startupParameters?.password;

    if (appConfig.remoteConfig != null && appConfig.remoteConfig!.devUrlConfigs != null) {
      urlConfigServer = appConfig.remoteConfig!.devUrlConfigs![appConfig.remoteConfig!.indexOfUsingUrlConfig];
    }
  } catch (e) {
    LOGGER.logD(pType: LOG_TYPE.GENERAL, pMessage: "No Dev Config found");
  }

  // Load last running config
  LastRunConfig lastRunConfig = LastRunConfig();
  List<String> supportedLang = ["en"];
  File? lastRunConfigFile = await fileMangerMobile.getIndependentFile(pPath: "$appName/lastRunConfig.json");
  if (lastRunConfigFile != null) {
    lastRunConfig = LastRunConfig.fromJson(pJson: jsonDecode(lastRunConfigFile.readAsStringSync()));
    // Set app version so version specific files can be get
    fileMangerMobile.setAppVersion(pVersion: lastRunConfig.version!);

    // Add supported languages by parsing all translation file names
    Directory? lang = fileMangerMobile.getDirectory(pPath: "languages/");
    if (lang != null && lang.existsSync()) {
      List<String> fileNames = lang.listSync().map((e) => e.path.split("/").last).toList();
      RegExp regExp = RegExp("_(?<name>[a-z]*)");

      fileNames.forEach((element) {
        RegExpMatch? match = regExp.firstMatch(element);
        if (match != null) {
          supportedLang.add(match.namedGroup("name")!);
        }
      });
    }
  }

  auth = lastRunConfig.authCode;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Service init
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // Api
  EndpointConfig endpointConfig = ConfigGenerator.generateFixedEndpoints();
  UrlConfig urlConfig = urlConfigServer;
  ApiConfig apiConfig = ApiConfig(urlConfig: urlConfig, endpointConfig: endpointConfig);
  IRepository repository = OnlineApiRepository(apiConfig: apiConfig);
  IController controller = ApiController();
  IApiService apiService = await IsolateApi.create(controller: controller, repository: repository);
  services.registerSingleton(apiService, signalsReady: true);

  // Config
  IConfigService configService = ConfigService(
    langCode: lastRunConfig.language ?? langCode,
    appName: appName,
    apiConfig: apiConfig,
    fileManager: fileMangerMobile,
    supportedLanguages: supportedLang,
    pStyleCallbacks: styleCallbacks,
    pLanguageCallbacks: languageCallbacks,
  );
  services.registerSingleton(configService, signalsReady: true);

  // Layout
  ILayoutService layoutService = await IsolateLayoutService.create();
  services.registerSingleton(layoutService, signalsReady: true);

  // Storage
  IStorageService storageService = await IsolateStorageService.create();
  services.registerSingleton(storageService, signalsReady: true);

  // Data
  IDataService dataService = DataService();
  services.registerSingleton(dataService, signalsReady: true);

  // Command
  ICommandService commandService = CommandService();
  services.registerSingleton(commandService, signalsReady: true);

  DefaultLoadingProgressHandler loadingProgressHandler = DefaultLoadingProgressHandler();
  loadingProgressHandler.isEnabled = false;
  (commandService as CommandService).progressHandler.add(DefaultLoadingProgressHandler());

  // UI
  IUiService uiService = UiService(customManager: pCustomManager, pContext: initContext);
  services.registerSingleton(uiService, signalsReady: true);

  // Send startup to server
  Size phoneSize = MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size;

  StartupCommand startupCommand = StartupCommand(
    language: lastRunConfig.language,
    reason: "InitApp",
    username: userName,
    password: password,
    screenWidth: phoneSize.width,
    screenHeight: phoneSize.height,
    authKey: auth,
  );
  await commandService.sendCommand(startupCommand);

  return true;
}
