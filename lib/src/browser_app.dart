import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'models/api/response_objects/language_response_object.dart';
import 'models/api/response_objects/menu/menu_item.dart';
import 'models/state/app_state.dart';
import 'models/state/routes/arguments/login_page_arguments.dart';
import 'models/state/routes/arguments/menu_page_arguments.dart';
import 'models/state/routes/arguments/open_screen_page_arguments.dart';
import 'models/state/routes/arguments/settings_page_arguments.dart';
import 'models/state/routes/arguments/startup_page_arguments.dart';
import 'models/state/routes/routes.dart';
import 'services/local/shared_preferences/shared_preferences_manager.dart';
import 'ui/pages/login_page.dart';
import 'ui/pages/menu_page.dart';
import 'ui/pages/open_screen_page.dart';
import 'ui/pages/settings_page.dart';
import 'ui/pages/startup_page.dart';
import 'util/config/server_config.dart';
import 'util/translation/app_localizations.dart';

class BrowserApp extends StatelessWidget {
  final ThemeData themeData;
  final AppState appState;
  final SharedPreferencesManager manager;
  final String initialRoute;
  final List<Locale> supportedLocales;
  final GlobalKey<NavigatorState> navigatorKey;

  const BrowserApp({
    Key? key,
    required this.themeData,
    required this.appState,
    required this.manager,
    required this.supportedLocales,
    required this.navigatorKey,
    this.initialRoute = Routes.startup,
  }) : super(key: key);

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    RouteSettings? newSettings = _isRouteAllowed(settings);

    if (newSettings != null) {
      settings = newSettings;

      // Getting all parameters out of route settings.
      List<String>? params = settings.name?.replaceAll('/?', '').split('&');

      if (params != null && params.length > 0) {
        for (final param in params) {
          if (appState.serverConfig == null &&
              (param.contains("appName=") || param.contains("baseUrl="))) {
            appState.serverConfig = ServerConfig(
                baseUrl: Uri.decodeFull(param.split('=')[1]),
                appName: param.split('=')[1]);
          }

          if (param.contains("appName=") &&
              (!appState.serverConfig!.isProd ||
                  !appState.serverConfig!.isPreview)) {
            appState.serverConfig!.appName = param.split("=")[1];
            manager.appName = appState.serverConfig!.appName;
          } else if (param.contains("baseUrl=") &&
              (!appState.serverConfig!.isProd ||
                  !appState.serverConfig!.isPreview)) {
            var baseUrl = param.split("=")[1];
            appState.serverConfig!.baseUrl = Uri.decodeFull(baseUrl);

            manager.baseUrl = appState.serverConfig!.baseUrl;
          } else if (param.contains("language=")) {
            appState.language = LanguageResponseObject(
                name: 'language',
                language: param.split('=')[1],
                languageResource:
                    appState.translationConfig.possibleTranslations[
                            'translation_${param.split('=')[1]}'] ??
                        '');

            manager.language = appState.language!.language;
          } else if (param.contains("username=")) {
            appState.serverConfig!.username = param.split("=")[1];
          } else if (param.contains("password=")) {
            appState.serverConfig!.password = param.split("=")[1];
          } else if (param.contains("mobileOnly=")) {
            appState.mobileOnly = param.split("=")[1] == 'true';
            manager.mobileOnly = appState.mobileOnly;
          } else if (param.contains("webOnly=")) {
            appState.webOnly = param.split("=")[1] == 'true';
            manager.webOnly = appState.webOnly;
          }
        }
      }

      switch (settings.name) {
        case Routes.startup:
          return MaterialPageRoute(
              settings: RouteSettings(
                  name: Routes.startup, arguments: settings.arguments),
              builder: (_) => StartupPage(
                    startupWidget: appState.widgetConfig.startupWidget,
                    appState: appState,
                    manager: manager,
                  ));
        case Routes.settings:
          SettingsPageArguments? arguments =
              settings.arguments as SettingsPageArguments?;

          return MaterialPageRoute(
              settings: RouteSettings(
                  name: Routes.settings, arguments: settings.arguments),
              builder: (_) => SettingsPage(
                    canPop: initialRoute == Routes.settings ? false : true,
                    hasError: arguments?.hasError ?? false,
                  ));
        case Routes.login:
          LoginPageArguments? arguments;

          if (settings.arguments != null) {
            arguments = settings.arguments as LoginPageArguments;
          }

          return MaterialPageRoute(
            settings: RouteSettings(
                name: Routes.login, arguments: settings.arguments),
            builder: (_) => LoginPage(
              appState: appState,
              manager: manager,
              lastUsername: arguments?.lastUsername,
            ),
          );
        case Routes.menu:
          MenuPageArguments? arguments;

          if (settings.arguments != null) {
            arguments = settings.arguments as MenuPageArguments;
          }

          return MaterialPageRoute(
              settings: RouteSettings(
                  name: Routes.menu, arguments: settings.arguments),
              builder: (_) => MenuPage(
                    listMenuItemsInDrawer:
                        arguments?.listMenuItemsInDrawer ?? true,
                    menuItems: arguments?.menuItems ?? <MenuItem>[],
                    response: arguments?.response,
                    appState: appState,
                    manager: manager,
                  ));
        case Routes.openScreen:
          if (settings.arguments != null) {
            OpenScreenPageArguments? arguments =
                settings.arguments as OpenScreenPageArguments;

            return MaterialPageRoute(
                settings: RouteSettings(
                    name: Routes.openScreen, arguments: settings.arguments),
                builder: (_) => OpenScreenPage(
                      appState: appState,
                      manager: manager,
                      screen: arguments.screen,
                    ));
          } else {
            return MaterialPageRoute(
                settings: RouteSettings(
                    name: Routes.startup, arguments: settings.arguments),
                builder: (_) => StartupPage(
                      startupWidget: null,
                      appState: appState,
                      manager: manager,
                    ));
          }
        default:
          return MaterialPageRoute(
              settings: RouteSettings(
                  name: Routes.startup, arguments: settings.arguments),
              builder: (_) => StartupPage(
                    startupWidget: null,
                    appState: appState,
                    manager: manager,
                  ));
      }
    } else {
      return MaterialPageRoute(
          settings: RouteSettings(
              name: Routes.startup, arguments: settings.arguments),
          builder: (_) => StartupPage(
                startupWidget: null,
                appState: appState,
                manager: manager,
              ));
    }
  }

  RouteSettings? _isRouteAllowed(RouteSettings settings) {
    if ((settings.name == Routes.login || settings.name == Routes.menu) &&
        appState.applicationStyle == null &&
        appState.fileConfig.images.isEmpty) {
      return null;
    }

    if (settings.name == Routes.menu && appState.userData == null) {
      return RouteSettings(
          name: Routes.login, arguments: LoginPageArguments(lastUsername: ''));
    }

    return settings;
  }

  String _onGenerateTitle(BuildContext context) {
    return appState.appConfig?.title ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      onGenerateRoute: _onGenerateRoute,
      onUnknownRoute: _onGenerateRoute,
      onGenerateTitle: _onGenerateTitle,
      theme: themeData,
      supportedLocales: this.supportedLocales,
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
