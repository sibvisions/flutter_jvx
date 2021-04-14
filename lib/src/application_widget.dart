import 'dart:developer';

import 'package:dartz/dartz.dart';
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

class ApplicationWidget extends StatelessWidget {
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

  ServerConfig? _getServerConfig(
      AppState appState, SharedPreferencesManager manager) {
    if (manager.initialStart &&
        appState.appConfig != null &&
        appState.appConfig!.initialConfig != null) {
      manager.initialStart = false;
      return appState.appConfig!.initialConfig;
    }

    manager.initialStart = false;

    if (devConfig != null &&
        manager.loadConfig &&
        devConfig!.baseUrl.isNotEmpty &&
        devConfig!.appName.isNotEmpty &&
        devConfig!.appMode.isNotEmpty) {
      final formattedUrl = _formatUrl(devConfig!.baseUrl);

      return ServerConfig(
          baseUrl: formattedUrl,
          appName: devConfig!.appName,
          appMode: devConfig!.appMode,
          username: devConfig!.username,
          password: devConfig!.password);
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
    if (appConfig != null) {
      return appConfig!;
    } else {
      late AppConfig config;

      Either<Failure, AppConfig>? either;

      try {
        either = await AppConfig.loadConfig(path: appConfigPath!);

        either.fold((failure) {
          log('Couldn\'t load app config. Taking default app config');
          config = AppConfig(
              handleSessionTimeout: true,
              rememberMeChecked: false,
              hideLoginCheckbox: false,
              loginColorsInverted: false,
              package: package,
              requestTimeout: 10);
        }, (appConfig) => config = appConfig);

        return config;
      } catch (e) {
        return AppConfig(
            package: package,
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
  Widget build(BuildContext context) {
    AppState appState = sl<AppState>();
    SharedPreferencesManager manager = sl<SharedPreferencesManager>();
    String initialRoute = '/';

    if (widgetConfig != null) {
      appState.widgetConfig = widgetConfig!;
    }

    if (appState.appVersion == null && appVersion != null) {
      appState.appVersion = appVersion;
    }

    if (screenManager != null) {
      appState.screenManager = screenManager!;
    }

    if (appState.listener == null) {
      appState.listener = appListener;
    }

    if (!kIsWeb) {
      // TODO: refactor
      getBaseDir().then((value) => appState.baseDirectory = value);
    }

    return FutureBuilder<AppConfig>(
        future: _getAppConfig(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            appState.appConfig = snapshot.data!;

            return RestartWidget(builder: (context) {
              appState.devConfig = devConfig;
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
