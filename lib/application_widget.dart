import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/utils/translation/supported_locale_manager.dart';

import 'core/models/app/app_state.dart';
import 'core/services/local/shared_preferences_manager.dart';
import 'core/ui/screen/i_screen_manager.dart';
import 'core/ui/screen/screen_manager.dart';
import 'core/ui/widgets/util/app_state_provider.dart';
import 'core/ui/widgets/util/restart_widget.dart';
import 'core/ui/widgets/util/shared_pref_provider.dart';
import 'core/utils/app/listener/app_listener.dart';
import 'core/utils/config/config.dart';
import 'core/utils/theme/theme_manager.dart';
import 'injection_container.dart';
import 'mobile_app.dart';

/// Entrypoint for the application.
/// 
/// Gets wrapped by [CustomApplicationWidget]
class ApplicationWidget extends StatelessWidget {
  final Config config;
  final IScreenManager screenManager;
  final bool handleSessionTimeout;
  final AppListener appListener;
  final bool package;
  final Widget welcomeWidget;

  const ApplicationWidget(
      {Key key,
      this.config,
      this.screenManager,
      this.handleSessionTimeout,
      this.appListener,
      this.package = false,
      this.welcomeWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Getting the current appState from GetIt.
    AppState appState = sl<AppState>();

    // Setting screen manager. If none was given a standard impl will be used.
    appState.screenManager = this.screenManager ?? ScreenManager();

    // Initializing screen manager
    appState.screenManager.init();

    // Setting app parameters
    appState.handleSessionTimeout = handleSessionTimeout ?? true;
    appState.appListener = this.appListener;
    appState.package = this.package;

    return RestartWidget(
      loadConfigBuilder: (bool shouldLoadConfig) =>
          ValueListenableBuilder<ThemeData>(
              valueListenable: sl<ThemeManager>(),
              builder:
                  (BuildContext context, ThemeData themeData, Widget child) {
                return SharedPrefProvider(
                  manager: sl<SharedPreferencesManager>(),
                  child: AppStateProvider(
                    appState: appState,
                    child: ValueListenableBuilder(
                        valueListenable: sl<SupportedLocaleManager>(),
                        builder: (BuildContext context,
                            List<Locale> supportedLocales, Widget child) {
                          return MobileApp(
                            welcomeWidget: this.welcomeWidget,
                            shouldLoadConfig: shouldLoadConfig,
                            themeData: themeData,
                            config: this.config,
                            supportedLocales: supportedLocales,
                          );
                        }),
                  ),
                );
              }),
    );
  }
}
