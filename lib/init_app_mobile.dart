import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/config/config_generator.dart';
import 'main.dart';
import 'src/model/command/api/startup_command.dart';
import 'src/model/config/api/api_config.dart';
import 'src/model/config/api/endpoint_config.dart';
import 'src/model/config/api/url_config.dart';
import 'src/model/config/config_file/app_config.dart';
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
  LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "initApp");

  // Needed to avoid CORS issues
  // ToDo find way to not do this
  HttpOverrides.global = MyHttpOverrides();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Init values
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // If not called will throw error when trying to access any files
  WidgetsFlutterBinding.ensureInitialized();

  // Load config
  var sharedPrefs = await SharedPreferences.getInstance();

  // Init values, should be possible to provide to initApp
  // TODO Get app name!
  String appName = sharedPrefs.getString("appName") ?? (kDebugMode ? "demo" : "");
  String? userName;
  String? password;

  await sharedPrefs.setString("appName", appName);
  offline = sharedPrefs.getBool("$appName.offline") ?? offline;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Load config files
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // Load Dev config
  UrlConfig urlConfigServer = UrlConfig.empty();
  try {
    String rawConfig = await rootBundle.loadString('assets/config/app.conf.json');
    AppConfig? appConfig = AppConfig.fromJson(json: jsonDecode(rawConfig));

    userName = appConfig.startupParameters?.username;
    password = appConfig.startupParameters?.password;

    if (appConfig.remoteConfig != null && appConfig.remoteConfig!.devUrlConfigs != null) {
      urlConfigServer = appConfig.remoteConfig!.devUrlConfigs![appConfig.remoteConfig!.indexOfUsingUrlConfig];
    }
  } catch (e) {
    LOGGER.logD(pType: LOG_TYPE.GENERAL, pMessage: "No Dev Config found");
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Service init
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // API
  EndpointConfig endpointConfig = ConfigGenerator.generateFixedEndpoints();
  UrlConfig urlConfig = urlConfigServer;
  ApiConfig apiConfig = ApiConfig(urlConfig: urlConfig, endpointConfig: endpointConfig);

  // Config
  IConfigService configService = ConfigService(
    appName: appName,
    apiConfig: apiConfig,
    fileManager: await FileMangerMobile.create(),
    sharedPrefs: sharedPrefs,
    pStyleCallbacks: styleCallbacks,
    pLanguageCallbacks: languageCallbacks,
  );
  services.registerSingleton(configService, signalsReady: true);

  IRepository repository = OnlineApiRepository(apiConfig: apiConfig);
  IController controller = ApiController();
  IApiService apiService = await IsolateApi.create(controller: controller, repository: repository);
  services.registerSingleton(apiService, signalsReady: true);

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
    reason: "InitApp",
    username: userName,
    password: password,
    screenWidth: phoneSize.width,
    screenHeight: phoneSize.height,
  );
  await commandService.sendCommand(startupCommand);

  return true;
}
