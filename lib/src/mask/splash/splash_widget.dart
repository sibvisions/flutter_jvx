import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/app_config.dart';
import '../../../util/logging/flutter_logger.dart';
import '../../model/command/api/set_api_config_command.dart';
import '../../model/command/api/startup_command.dart';
import '../../model/config/api/api_config.dart';
import '../../service/api/i_api_service.dart';
import '../../service/api/shared/repository/offline_api_repository.dart';
import '../../service/api/shared/repository/online_api_repository.dart';
import '../../service/command/i_command_service.dart';
import '../../service/command/impl/command_service.dart';
import '../../service/config/i_config_service.dart';
import '../../service/config/impl/config_service.dart';
import '../../service/service.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/config_util.dart';
import '../../util/init_config.dart';
import '../../util/loading_handler/loading_progress_handler.dart';
import '../error/error_dialog.dart';
import 'loading_widget.dart';

class SplashWidget extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final InitConfig? initConfig;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const SplashWidget({
    Key? key,
    this.initConfig,
  }) : super(key: key);

  @override
  State<SplashWidget> createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  late Future<void> initAppFuture;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    initAppFuture = initApp(
      initContext: context,
      initConfig: widget.initConfig,
    ).catchError((error, stackTrace) {
      LOGGER.logE(pType: LogType.GENERAL, pError: error, pStacktrace: stackTrace);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async {
              await SystemNavigator.pop();
              return false;
            },
            child: AlertDialog(
              backgroundColor: Theme.of(context).cardColor.withAlpha(255),
              title: const Text("FATAL ERROR"),
              content: Text(error.toString()),
              actions: _getButtons(context),
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initAppFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return widget.initConfig?.loadingBuilder?.call(context) ?? const LoadingWidget();
      },
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Get all possible actions
  List<Widget> _getButtons(BuildContext context) {
    List<Widget> actions = [];

    if (!kIsWeb) {
      actions.add(
        TextButton(
          onPressed: () {
            SystemNavigator.pop();
          },
          child: const Text(
            "Exit App",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return actions;
  }

  Future<void> initApp({
    required BuildContext initContext,
    InitConfig? initConfig,
  }) async {
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

    uiService.setAppManager(initConfig?.appManager);

    // Load config files
    AppConfig? devConfig;
    if (!kReleaseMode) {
      devConfig = await ConfigUtil.readDevConfig();
      if (devConfig != null) {
        LOGGER.logI(pType: LogType.CONFIG, pMessage: "Found dev config, overriding values");
      }
    }

    AppConfig appConfig =
        const AppConfig.empty().merge(initConfig?.appConfig).merge(await ConfigUtil.readAppConfig()).merge(devConfig);
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
    initConfig?.styleCallbacks?.forEach((element) => configService.registerStyleCallback(element));
    configService.disposeLanguageCallbacks();
    initConfig?.languageCallbacks?.forEach((element) => configService.registerLanguageCallback(element));
    configService.disposeImagesCallbacks();
    initConfig?.imagesCallbacks?.forEach((element) => configService.registerImagesCallback(element));

    //Init saved app style
    var appStyle = configService.getAppStyle();
    if (appStyle.isNotEmpty) {
      await configService.setAppStyle(appStyle);
    }

    configService.setPhoneSize(!kIsWeb ? MediaQueryData.fromWindow(WidgetsBinding.instance.window).size : null);

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // API init
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    var repository = configService.isOffline() ? OfflineApiRepository() : OnlineApiRepository();
    await repository.start();
    await apiService.setRepository(repository);

    if (configService.getAppName() != null && configService.getBaseUrl() != null) {
      if (configService.getVersion() != null) {
        configService.loadLanguages();
      }

      if (!configService.isOffline()) {
        await commandService.sendCommand(SetApiConfigCommand(
          apiConfig: ApiConfig(serverConfig: configService.getServerConfig()),
          reason: "Startup Api Config",
        ));

        bool retry = false;
        do {
          try {
            // Send startup to server
            await commandService.sendCommand(StartupCommand(
              reason: "InitApp",
              username: configService.getAppConfig()!.serverConfig!.username,
              password: configService.getAppConfig()!.serverConfig!.password,
            ));
            break;
          } catch (e, stackTrace) {
            LOGGER.logE(pType: LogType.GENERAL, pError: e, pStacktrace: stackTrace);
            bool? dialogResult = await uiService.openDialog(
              pBuilder: (context) => ErrorDialog(
                message: IUiService.getErrorMessage(e),
                gotToSettings: true,
                dismissible: false,
                retry: true,
              ),
              pIsDismissible: false,
            );
            retry = dialogResult ?? false;
          }
        } while (retry);
      } else {
        uiService.routeToMenu(pReplaceRoute: true);
      }
    } else {
      uiService.routeToSettings(pReplaceRoute: true);
    }
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
