import 'dart:developer';

import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../injection_container.dart';
import 'browser_app.dart';
import 'mobile_app.dart';
import 'models/api/errors/failure.dart';
import 'models/state/app_state.dart';
import 'models/state/routes/routes.dart';
import 'services/local/locale/supported_locale_manager.dart';
import 'services/local/shared_preferences/shared_preferences_manager.dart';
import 'ui/screen/core/manager/i_screen_manager.dart';
import 'ui/util/inherited_widgets/app_state_provider.dart';
import 'ui/util/inherited_widgets/shared_preferences_provider.dart';
import 'ui/util/restart_widget.dart';
import 'util/app/listener/app_listener.dart';
import 'util/app/version/app_version.dart';
import 'util/config/app_config.dart';
import 'util/config/dev_config.dart';
import 'util/config/server_config.dart';
import 'util/config/widget_config.dart';
import 'util/download/download_helper.dart';
import 'util/theme/theme_manager.dart';

class ApplicationWidget extends StatefulWidget {
  final AppConfig? appConfig;
  final DevConfig? devConfig;
  final String? appConfigPath;
  final AppListener? appListener;
  final IScreenManager? screenManager;
  final AppVersion? appVersion;
  final WidgetConfig? widgetConfig;
  final bool package;

  const ApplicationWidget(
      {Key? key,
      this.appConfig,
      this.appConfigPath = 'assets/config/app.conf.yaml',
      this.appListener,
      this.screenManager,
      this.devConfig,
      this.package = false,
      this.widgetConfig,
      this.appVersion})
      : assert(appConfig != null || appConfigPath != null),
        super(key: key);

  @override
  _ApplicationWidgetState createState() => _ApplicationWidgetState();
}

class _ApplicationWidgetState extends State<ApplicationWidget> {
  late Future<AppConfig> appConfigFuture;
  late AppState appState;
  late SharedPreferencesManager manager;

  ServerConfig? _getServerConfig(
      AppState appState, SharedPreferencesManager manager) {
    if (manager.initialStart &&
        appState.appConfig != null &&
        appState.appConfig!.initialConfig != null) {
      manager.initialStart = false;
      return appState.appConfig!.initialConfig;
    }

    manager.initialStart = false;

    if (widget.devConfig != null &&
        manager.loadConfig &&
        widget.devConfig!.baseUrl.isNotEmpty &&
        widget.devConfig!.appName.isNotEmpty &&
        widget.devConfig!.appMode.isNotEmpty) {
      final formattedUrl = _formatUrl(widget.devConfig!.baseUrl);

      return ServerConfig(
          baseUrl: formattedUrl,
          appName: widget.devConfig!.appName,
          appMode: widget.devConfig!.appMode,
          username: widget.devConfig!.username,
          password: widget.devConfig!.password);
    } else if (manager.baseUrl != null ||
        manager.appName != null ||
        manager.appMode != null) {
      manager.loadConfig = true;

      return ServerConfig(
          baseUrl: manager.baseUrl ?? '',
          appName: manager.appName ?? '',
          appMode: manager.appMode ?? 'full');
    } else {
      manager.loadConfig = true;

      return null;
    }
  }

  Future<AppConfig> _getAppConfig() async {
    if (widget.appConfig != null) {
      return widget.appConfig!;
    } else {
      late AppConfig config;

      dartz.Either<Failure, AppConfig>? either;

      try {
        either = await AppConfig.loadConfig(path: widget.appConfigPath!);

        either.fold((failure) {
          log('Couldn\'t load app config. Taking default app config');
          config = AppConfig(
              handleSessionTimeout: true,
              rememberMeChecked: false,
              hideLoginCheckbox: false,
              loginColorsInverted: false,
              package: widget.package,
              requestTimeout: 10);
        }, (appConfig) => config = appConfig);

        return config;
      } catch (e) {
        return AppConfig(
            package: widget.package,
            rememberMeChecked: false,
            hideLoginCheckbox: false,
            handleSessionTimeout: true,
            loginColorsInverted: false,
            requestTimeout: 10);
      }
    }
  }

  String _formatUrl(String baseUrl) {
    List<String> splittedUrl = baseUrl.split('/');

    if (splittedUrl.length >= 3 && splittedUrl.length <= 4) {
      return baseUrl + '/services/mobile';
    }

    return baseUrl;
  }

  @override
  void initState() {
    super.initState();

    appState = sl<AppState>();
    manager = sl<SharedPreferencesManager>();

    appConfigFuture = _getAppConfig();

    if (widget.widgetConfig != null) {
      appState.widgetConfig = widget.widgetConfig!;
    }

    if (appState.appVersion == null && widget.appVersion != null) {
      appState.appVersion = widget.appVersion;
    }

    if (widget.screenManager != null) {
      appState.screenManager = widget.screenManager!;
    }

    if (appState.listener == null) {
      appState.listener = widget.appListener;
    }

    if (!kIsWeb) {
      // TODO: refactor
      getBaseDir().then((value) => appState.baseDirectory = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    String initialRoute = '/';

    return FutureBuilder<AppConfig>(
        future: appConfigFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            appState.appConfig = snapshot.data!;

            return RestartWidget(builder: (context) {
              appState.devConfig = widget.devConfig;
              appState.serverConfig = _getServerConfig(appState, manager);

              if (appState.serverConfig != null) {
                manager.baseUrl = appState.serverConfig!.baseUrl;
                manager.appName = appState.serverConfig!.appName;
                manager.appMode = appState.serverConfig!.appMode;
              }

              if (appState.serverConfig == null ||
                  (appState.serverConfig!.baseUrl.isEmpty ||
                      appState.serverConfig!.appName.isEmpty)) {
                initialRoute = Routes.settings;
              } else {
                initialRoute = Routes.startup;
              }

              return AppStateProvider(
                appState: appState,
                child: SharedPreferencesProvider(
                  manager: sl<SharedPreferencesManager>(),
                  child: ValueListenableBuilder<ThemeData>(
                    valueListenable: sl<ThemeManager>(),
                    builder: (BuildContext context, ThemeData themeData,
                        Widget? child) {
                      return ValueListenableBuilder(
                        valueListenable: sl<SupportedLocaleManager>(),
                        builder: (BuildContext context, List<Locale> locales,
                            Widget? child) {
                          if (kIsWeb) {
                            return BrowserApp(
                                appState: appState,
                                themeData: themeData,
                                initialRoute: initialRoute,
                                manager: sl<SharedPreferencesManager>(),
                                supportedLocales: locales);
                          } else {
                            return MobileApp(
                                appState: appState,
                                themeData: themeData,
                                initialRoute: initialRoute,
                                manager: sl<SharedPreferencesManager>(),
                                supportedLocales: locales);
                          }
                        },
                      );
                    },
                  ),
                ),
              );
            });
          } else {
            return Container();
          }
        });
  }
}
