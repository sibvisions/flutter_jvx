import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'models/state/app_state.dart';
import 'models/state/routes/arguments/login_page_arguments.dart';
import 'models/state/routes/arguments/menu_page_arguments.dart';
import 'models/state/routes/arguments/open_screen_page_arguments.dart';
import 'models/state/routes/arguments/settings_page_arguments.dart';
import 'models/state/routes/arguments/startup_page_arguments.dart';
import 'models/state/routes/default_page_route.dart';
import 'models/state/routes/routes.dart';
import 'services/local/shared_preferences/shared_preferences_manager.dart';
import 'ui/pages/login_page.dart';
import 'ui/pages/menu_page.dart';
import 'ui/pages/open_screen_page.dart';
import 'ui/pages/settings_page.dart';
import 'ui/pages/startup_page.dart';
import 'util/translation/app_localizations.dart';

class MobileApp extends StatelessWidget {
  final ThemeData themeData;
  final AppState appState;
  final SharedPreferencesManager manager;
  final String initialRoute;
  final List<Locale> supportedLocales;

  const MobileApp({
    Key? key,
    required this.themeData,
    required this.appState,
    required this.manager,
    required this.supportedLocales,
    this.initialRoute = Routes.startup,
  }) : super(key: key);

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.startup:
        StartupPageArguments? arguments;
        if (settings.arguments != null)
          arguments = settings.arguments as StartupPageArguments;
        return DefaultPageRoute(
            settings: RouteSettings(
                name: Routes.startup, arguments: settings.arguments),
            builder: (_) => StartupPage(
                  startupWidget: arguments?.startupWidget ??
                      appState.widgetConfig.startupWidget,
                  appState: appState,
                  manager: manager,
                ));
      case Routes.settings:
        SettingsPageArguments? arguments =
            settings.arguments as SettingsPageArguments?;

        bool? canPop = arguments?.canPop;

        if (canPop == null) {
          if (initialRoute == Routes.settings) {
            canPop = false;
          } else {
            canPop = true;
          }
        }

        return DefaultPageRoute(
            settings: RouteSettings(
                name: Routes.settings, arguments: settings.arguments),
            builder: (_) => SettingsPage(
                  canPop: canPop!,
                  hasError: arguments?.hasError ?? false,
                ));
      case Routes.login:
        LoginPageArguments arguments = settings.arguments as LoginPageArguments;

        return DefaultPageRoute(
          settings:
              RouteSettings(name: Routes.login, arguments: settings.arguments),
          builder: (_) => LoginPage(
            appState: appState,
            manager: manager,
            lastUsername: arguments.lastUsername,
          ),
        );
      case Routes.menu:
        MenuPageArguments arguments = settings.arguments as MenuPageArguments;

        return DefaultPageRoute(
          settings:
              RouteSettings(name: Routes.menu, arguments: settings.arguments),
          builder: (_) => MenuPage(
            listMenuItemsInDrawer: arguments.listMenuItemsInDrawer,
            menuItems: arguments.menuItems,
            response: arguments.response,
            appState: appState,
            manager: manager,
          ),
        );
      case Routes.openScreen:
        OpenScreenPageArguments arguments =
            settings.arguments as OpenScreenPageArguments;

        return DefaultPageRoute(
            settings: RouteSettings(
                name: Routes.openScreen, arguments: settings.arguments),
            builder: (_) => OpenScreenPage(
                appState: appState,
                manager: manager,
                screen: arguments.screen));
      default:
        return DefaultPageRoute(
            settings: RouteSettings(
                name: Routes.startup, arguments: settings.arguments),
            builder: (_) => StartupPage(
                  startupWidget: null,
                  appState: appState,
                  manager: manager,
                ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: themeData,
      initialRoute: initialRoute,
      onGenerateRoute: _onGenerateRoute,
      onUnknownRoute: _onGenerateRoute,
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
