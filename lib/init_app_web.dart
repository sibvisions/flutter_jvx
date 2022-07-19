import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/config/config_generator.dart';
import 'main.dart';
import 'src/model/command/api/startup_command.dart';
import 'src/model/config/api/api_config.dart';
import 'src/model/config/api/endpoint_config.dart';
import 'src/model/config/api/url_config.dart';
import 'src/model/custom/custom_screen_manager.dart';
import 'src/service/api/i_api_service.dart';
import 'src/service/api/impl/default/api_service.dart';
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
import 'src/service/layout/impl/layout_service.dart';
import 'src/service/service.dart';
import 'src/service/storage/i_storage_service.dart';
import 'src/service/storage/impl/default/storage_service.dart';
import 'src/service/ui/i_ui_service.dart';
import 'src/service/ui/impl/ui_service.dart';
import 'util/file/file_manager_web.dart';
import 'util/logging/flutter_logger.dart';

Future<bool> initApp({
  CustomScreenManager? pCustomManager,
  required BuildContext initContext,
  List<Function>? languageCallbacks,
  List<Function>? styleCallbacks,
}) async {
  LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "initApp");

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Service init
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // Config
  IConfigService configService = ConfigService(
    sharedPrefs: await SharedPreferences.getInstance(),
    fileManager: FileManagerWeb(),
    pStyleCallbacks: styleCallbacks,
    pLanguageCallbacks: languageCallbacks,
  );
  services.registerSingleton(configService, signalsReady: true);

  // Layout
  ILayoutService layoutService = LayoutService();
  services.registerSingleton(layoutService, signalsReady: true);

  // Storage
  IStorageService storageService = StorageService();
  services.registerSingleton(storageService, signalsReady: true);

  // Data
  IDataService dataService = DataService();
  services.registerSingleton(dataService, signalsReady: true);

  // Command
  ICommandService commandService = CommandService();
  services.registerSingleton(commandService, signalsReady: true);

  // UI
  IUiService uiService = UiService(customManager: pCustomManager, pContext: initContext);
  services.registerSingleton(uiService, signalsReady: true);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Load config files
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  //TODO Load Dev config

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // API init
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // API
  ApiConfig apiConfig = ApiConfig(
    urlConfig: ConfigGenerator.generateMobileServerUrl("localhost", 8888),
    endpointConfig: ConfigGenerator.generateFixedEndpoints(),
  );
  (configService as ConfigService).setApiConfig(apiConfig);

  IApiService apiService = ApiService(
    repository: OnlineApiRepository(apiConfig: apiConfig),
    controller: ApiController(),
  );
  services.registerSingleton(apiService, signalsReady: true);

  StartupCommand startupCommand = StartupCommand(reason: "InitApp");
  await commandService.sendCommand(startupCommand);

  return true;
}
