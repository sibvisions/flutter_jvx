import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/models/app/app_state.dart';
import 'core/models/app/login_arguments.dart';
import 'core/models/app/menu_arguments.dart';
import 'core/models/app/screen_arguments.dart';
import 'core/services/local/shared_preferences_manager.dart';
import 'core/ui/pages/login_page.dart';
import 'core/ui/pages/menu_page.dart';
import 'core/ui/pages/open_screen_page.dart';
import 'core/ui/pages/settings_page.dart';
import 'core/ui/pages/startup_page.dart';
import 'core/ui/widgets/util/app_state_provider.dart';
import 'core/ui/widgets/util/shared_pref_provider.dart';
import 'core/utils/config/config.dart';
import 'core/utils/translation/app_localizations.dart';

class MobileApp extends StatelessWidget {
  final bool shouldLoadConfig;
  final ThemeData themeData;
  final Config config;

  const MobileApp(
      {Key key,
      @required this.shouldLoadConfig,
      @required this.themeData,
      this.config})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: MaterialApp(
        onGenerateRoute: (RouteSettings settings) {
          List<String> params = settings.name.replaceAll('/?', '').split('&');
          SharedPreferencesManager manager = SharedPrefProvider.of(context).manager;
          AppState appState = AppStateProvider.of(context).appState;


          if (params.length > 0) {
            for (final param in params) {
              if (param.contains("appName=")) {
                appState.appName = param.split("=")[1];
              } else if (param.contains("baseUrl=")) {
                var baseUrl = param.split("=")[1];
                appState.baseUrl = Uri.decodeFull(baseUrl);
              } else if (param.contains("language=")) {
                appState.language = param.split("=")[1];
              } else if (param.contains("username=")) {
                appState.username = param.split("=")[1];
              } else if (param.contains("password=")) {
                appState.password = param.split("=")[1];
              } else if (param.contains("mobileOnly=")) {
                appState.mobileOnly = param.split("=")[1] == 'true';
              } else if (param.contains("webOnly=")) {
                appState.webOnly = param.split("=")[1] == 'true';
              }
            }

            manager.setAppData(appName: appState.appName, baseUrl: appState.baseUrl, language: appState.language, picSize: appState.picSize);

            manager.setLoginData(username: appState.username, password: appState.password);

            if (appState.mobileOnly != null) {
              manager.setMobileOnly(appState.mobileOnly);
            }
          }

          switch (settings.name) {
            case '/menu':
              MenuArguments arguments = settings.arguments;

              return MaterialPageRoute(
                builder: (_) => MenuPage(
                  listMenuItemsInDrawer: arguments.listMenuItemsInDrawer,
                  menuItems: arguments.menuItems,
                  welcomeScreen: arguments.welcomeScreen,
                ),
              );
              break;
            case '/screen':
              ScreenArguments arguments = settings.arguments;
              
              return MaterialPageRoute(
                builder: (_) => OpenScreenPage(
                  items: arguments.items,
                  menuComponentId: arguments.menuComponentId,
                  response: arguments.response,
                  templateName: arguments.templateName,
                  title: arguments.title, 
                )
              );
              break;
            case '/login':
              return MaterialPageRoute(
                builder: (_) => LoginPage(
                  lastUsername: (settings.arguments as LoginArguments).lastUsername,
                )
              );
              break;
            case '/settings':
              return MaterialPageRoute(
                builder: (_) => SettingsPage(
                  appState: appState,
                  manager: manager,
                ) 
              );
              break;
            case '/startup':
              return MaterialPageRoute(
                builder: (_) => StartupPage(
                  shouldLoadConfig: this.shouldLoadConfig,
                  config: this.config,
                ),
              );
          }

          return null;
        },
        localizationsDelegates: [
          const AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [const Locale('en'), const Locale('de')],
        title: 'JVx Mobile',
        theme: this.themeData,
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: false,
        initialRoute: '/startup',
      ),
    );
  }
}
