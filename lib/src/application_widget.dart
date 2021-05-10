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

/// Widget the runs the whole application.
///
/// Takes a list of parameters which can customize the application.
class ApplicationWidget extends StatefulWidget {
  /// Config for the application
  ///
  /// Either [appConfig] or [appConfigPath] must not be null.
  final AppConfig? appConfig;

  /// For developing to force the baseUrl and appName on the application.
  final DevConfig? devConfig;

  /// Path to the [AppConfig].
  ///
  /// Either [appConfig] or [appConfigPath] must not be null.
  final String? appConfigPath;

  /// Instance for controlling the application on special events.
  ///
  /// Such as starting the application or opening a screen.
  final AppListener? appListener;

  /// Instance for managing [CustomScreen]s and [MenuItem]s.
  final IScreenManager? screenManager;

  /// For defining the own version
  ///
  /// Will be shown in the [SettingsPageWidget].
  final AppVersion? appVersion;

  /// Config for defining `startupWidget` and `welcomeWidget`.
  final WidgetConfig? widgetConfig;

  /// `true` if the application is used as a package.
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
  late GlobalKey<NavigatorState> navigatorKey;

  /// Method for loading the [ServerConfig].
  ServerConfig? _getServerConfig(
      AppState appState, SharedPreferencesManager manager) {
    // If the app is started the first time
    // and the AppConfig defined has an initial ServerConfig,
    // the application will save them in the SharedPreferences
    if (manager.initialStart) {
      manager.initialStart = false;

      if (appState.appConfig != null &&
          appState.appConfig!.initialConfig != null) {
        manager.baseUrl = appState.appConfig?.initialConfig?.baseUrl;
        manager.appName = appState.appConfig?.initialConfig?.appName;
        manager.appMode = appState.appConfig?.initialConfig?.appMode ?? 'full';

        return appState.appConfig!.initialConfig;
      }
    }

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

  /// Method for loading the [AppConfig] when no one is set.
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

  void _setAppState(AppState appState) {
    if (widget.widgetConfig != null) {
      appState.widgetConfig = widget.widgetConfig!;
    }

    if (appState.appVersion == null && widget.appVersion != null) {
      appState.appVersion = widget.appVersion;
    }

    if (widget.screenManager != null) {
      appState.screenManager = widget.screenManager!;

      appState.screenManager.init(navigatorKey);
    }

    if (appState.listener == null) {
      appState.listener = widget.appListener;
    }

    if (!kIsWeb) {
      DownloadHelper.getBaseDir()
          .then((value) => appState.baseDirectory = value);
    }
  }

  @override
  void initState() {
    super.initState();

    navigatorKey = GlobalKey<NavigatorState>();

    appConfigFuture = _getAppConfig();

    // Getting dependency injected instances
    appState = sl<AppState>();
    manager = sl<SharedPreferencesManager>();

    _setAppState(appState);
  }

  @override
  Widget build(BuildContext context) {
    String initialRoute = '/';

    return RestartWidget(builder: (context) {
      return FutureBuilder<AppConfig>(
          future: appConfigFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (appState.appConfig == null) {
                appState.appConfig = snapshot.data!;
              }

              appState.serverConfig = _getServerConfig(appState, manager);

              // When ServerConfig is null the initial Route will be the Settings Route.
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
                                navigatorKey: navigatorKey,
                                appState: appState,
                                themeData: themeData,
                                initialRoute: initialRoute,
                                manager: sl<SharedPreferencesManager>(),
                                supportedLocales: locales);
                          } else {
                            return MobileApp(
                                navigatorKey: navigatorKey,
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
            } else {
              return Container();
            }
          });
    });
  }
}
