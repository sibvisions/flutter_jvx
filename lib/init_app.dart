import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'data/config/app_config.dart';
import 'main.dart';
import 'src/model/command/api/startup_command.dart';
import 'src/model/config/api/api_config.dart';
import 'src/model/custom/custom_screen_manager.dart';
import 'src/service/api/i_api_service.dart';
import 'src/service/api/shared/controller/api_controller.dart';
import 'src/service/api/shared/repository/offline_api_repository.dart';
import 'src/service/api/shared/repository/online_api_repository.dart';
import 'src/service/command/i_command_service.dart';
import 'src/service/command/impl/command_service.dart';
import 'src/service/config/i_config_service.dart';
import 'src/service/config/impl/config_service.dart';
import 'src/service/service.dart';
import 'src/service/ui/i_ui_service.dart';
import 'util/config_util.dart';
import 'util/loading_handler/default_loading_progress_handler.dart';
import 'util/logging/flutter_logger.dart';

Future<void> initApp({
  required BuildContext initContext,
  AppConfig? appConfig,
  CustomScreenManager? pCustomManager,
  List<Function(Map<String, String> style)>? styleCallbacks,
  List<Function(String language)>? languageCallbacks,
}) async {
  LOGGER.logD(pType: LOG_TYPE.UI, pMessage: "initApp");

  HttpOverrides.global = MyHttpOverrides();

  IConfigService configService = services<IConfigService>();
  ICommandService commandService = services<ICommandService>();
  IUiService uiService = services<IUiService>();
  IApiService apiService = services<IApiService>();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Load config
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  (commandService as CommandService).progressHandler.clear();
  (commandService as CommandService).progressHandler.add(DefaultLoadingProgressHandler()..isEnabled = false);

  uiService.setCustomManager(pCustomManager);
  uiService.setRouteContext(pContext: initContext);

  // Load config files
  appConfig ??= await ConfigUtil.readDevConfig();
  appConfig ??= await ConfigUtil.readAppConfig();

  if (appConfig == null) {
    LOGGER.logI(pType: LOG_TYPE.CONFIG, pMessage: "No Config found, using default values");
    appConfig = AppConfig();
  }
  (configService as ConfigService).setAppConfig(appConfig);

  if (appConfig.serverConfig.baseUrl != null) {
    var baseUri = Uri.parse(appConfig.serverConfig.baseUrl!);
    //If no https on a remote host, you have to use localhost because of secure cookies
    if (kIsWeb && kDebugMode && baseUri.host != "localhost" && !baseUri.isScheme("https")) {
      await configService.setBaseUrl(baseUri.replace(host: "localhost").toString());
    }
  }

  configService.disposeStyleCallbacks();
  styleCallbacks?.forEach((element) => configService.registerStyleCallback(element));
  configService.disposeLanguageCallbacks();
  languageCallbacks?.forEach((element) => configService.registerLanguageCallback(element));

  if (configService.getBaseUrl() != null) {
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // API init
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    // API

    var controller = ApiController();
    var repository = configService.isOffline()
        ? OfflineApiRepository()
        : OnlineApiRepository(apiConfig: ApiConfig(serverConfig: configService.getServerConfig()!));
    await repository.start();
    await apiService.setController(controller);
    await apiService.setRepository(repository);

    configService.setPhoneSize(!kIsWeb ? MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size : null);

    if (!configService.isOffline()) {
      // Send startup to server

      StartupCommand startupCommand = StartupCommand(
        reason: "InitApp",
        username: configService.getUsername(),
        password: configService.getPassword(),
      );
      await commandService.sendCommand(startupCommand);
    } else {
      uiService.routeToMenu();
    }
  } else {
    uiService.routeToSettings();
  }
}
