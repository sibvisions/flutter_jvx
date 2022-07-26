import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/config/config_generator.dart';
import 'main.dart';
import 'src/model/command/api/startup_command.dart';
import 'src/model/config/api/api_config.dart';
import 'src/model/config/api/url_config.dart';
import 'src/model/config/config_file/app_config.dart';
import 'src/model/custom/custom_screen_manager.dart';
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
import 'src/service/layout/i_layout_service.dart';
import 'src/service/layout/impl/isolate/isolate_layout_service.dart';
import 'src/service/layout/impl/layout_service.dart';
import 'src/service/service.dart';
import 'src/service/storage/i_storage_service.dart';
import 'src/service/storage/impl/default/storage_service.dart';
import 'src/service/storage/impl/isolate/isolate_storage_service.dart';
import 'src/service/ui/i_ui_service.dart';
import 'src/service/ui/impl/ui_service.dart';
import 'util/config_util.dart';
import 'util/file/file_manager.dart';
import 'util/loading_handler/default_loading_progress_handler.dart';
import 'util/logging/flutter_logger.dart';

Future<void> initApp({
  CustomScreenManager? pCustomManager,
  required BuildContext initContext,
  List<Function(Map<String, String> style)>? styleCallbacks,
  List<Function(String language)>? languageCallbacks,
}) async {
  LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "initApp");

  HttpOverrides.global = MyHttpOverrides();

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

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Load config files
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  (commandService as CommandService).progressHandler.clear();
  (commandService as CommandService).progressHandler.add(DefaultLoadingProgressHandler()..isEnabled = false);

  uiService.setCustomManager(pCustomManager);
  uiService.setRouteContext(pContext: initContext);

  // Load Dev config
  AppConfig? appConfig = await ConfigUtil.readAppConfig();

  UrlConfig urlConfigServer = ConfigUtil.createUrlConfig(
    pAppConfig: appConfig,
    pUrlConfig: UrlConfig.empty(),
  );

  configService.disposeStyleCallbacks();
  styleCallbacks?.forEach((element) => configService.registerStyleCallback(element));
  configService.disposeLanguageCallbacks();
  languageCallbacks?.forEach((element) => configService.registerLanguageCallback(element));

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // API init
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // API
  ApiConfig apiConfig = ApiConfig(
    urlConfig: urlConfigServer,
    endpointConfig: ConfigGenerator.generateFixedEndpoints(),
  );
  (configService as ConfigService).setApiConfig(apiConfig);

  var controller = ApiController();
  var repository = configService.isOffline() ? OfflineApiRepository() : OnlineApiRepository(apiConfig: apiConfig);
  await repository.start();
  IApiService apiService = ApiService(controller: controller, repository: repository);
  services.registerSingleton(apiService);

  configService.setPhoneSize(!kIsWeb ? MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size : null);

  if (!configService.isOffline()) {
    // Send startup to server

    StartupCommand startupCommand = StartupCommand(
      reason: "InitApp",
      username: appConfig?.startupParameters?.username,
      password: appConfig?.startupParameters?.password,
    );
    await commandService.sendCommand(startupCommand);
  } else {
    uiService.routeToMenu();
  }
}
