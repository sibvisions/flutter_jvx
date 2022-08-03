import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'config/app_config.dart';
import 'custom/custom_screen_manager.dart';
import 'main.dart';
import 'src/model/command/api/set_api_config_command.dart';
import 'src/model/command/api/startup_command.dart';
import 'src/model/config/api/api_config.dart';
import 'src/service/api/i_api_service.dart';
import 'src/service/api/shared/repository/offline_api_repository.dart';
import 'src/service/api/shared/repository/online_api_repository.dart';
import 'src/service/command/i_command_service.dart';
import 'src/service/command/impl/command_service.dart';
import 'src/service/config/i_config_service.dart';
import 'src/service/config/impl/config_service.dart';
import 'src/service/service.dart';
import 'src/service/ui/i_ui_service.dart';
import 'src/util/config_util.dart';
import 'src/util/loading_handler/loading_progress_handler.dart';
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

  (commandService as CommandService).progressHandler
    ..clear()
    ..add(LoadingProgressHandler());

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

  configService.setPhoneSize(!kIsWeb ? MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size : null);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // API init
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  var repository = configService.isOffline() ? OfflineApiRepository() : OnlineApiRepository();
  await repository.start();
  await apiService.setRepository(repository);

  if (configService.getAppName() != null && configService.getBaseUrl() != null) {
    if (!configService.isOffline()) {
      await commandService.sendCommand(SetApiConfigCommand(
        apiConfig: ApiConfig(serverConfig: configService.getServerConfig()),
        reason: "Startup Api Config",
      ));

      // Send startup to server
      await commandService.sendCommand(StartupCommand(
        //   appName: widget.appState.serverConfig!.appName,
        //   screenWidth: MediaQuery.of(context).size.width.toInt(),
        //   screenHeight: MediaQuery.of(context).size.height.toInt(),
        //   appMode: widget.appState.serverConfig!.appMode,
        //   readAheadLimit: widget.appState.readAheadLimit,
        //   deviceId: _getDeviceId(),
        //   language: _startupLanguage,
        //   clientId: '',
        //   deviceMode: kIsWeb ? 'desktop' : 'mobile',
        //   technology: deviceInfo.technology,
        //   osName: deviceInfo.osName,
        //   osVersion: deviceInfo.osVersion,
        //   appVersion: deviceInfo.appVersion,
        //   deviceType: deviceInfo.deviceType,
        //   deviceTypeModel: deviceInfo.deviceTypeModel,
        //   authKey: widget.manager.authKey,
        //   username: widget.appState.serverConfig!.username,
        //   password: widget.appState.serverConfig!.password,
        reason: "InitApp",
        username: configService.getUsername(),
        password: configService.getPassword(),
      ));
    } else {
      uiService.routeToMenu(pReplaceRoute: true);
    }
  } else {
    uiService.routeToSettings(pReplaceRoute: true);
  }
}
