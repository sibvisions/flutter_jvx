import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/ui/page/menu_arguments.dart';
import 'package:jvx_flutterclient/ui/page/screen_arguments.dart';
import 'package:jvx_flutterclient/ui_refactor_2/page/open_screen_page.dart';
import 'ui/page/menu_page.dart';
import 'utils/shared_preferences_helper.dart';
import 'utils/text_utils.dart';
import 'ui/page/settings_page.dart';
import 'ui/page/startup_page.dart';
import 'utils/config.dart';
import 'utils/translations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'utils/globals.dart' as globals;

class MobileApp extends StatelessWidget {
  final bool loadConf;
  final ThemeData theme;
  final Config config;

  MobileApp(this.loadConf, this.theme, {this.config});

  GestureDetector materialApp(BuildContext context, ThemeData theme) =>
      GestureDetector(
          onTap: () => TextUtils.unfocusCurrentTextfield(context),
          child: MaterialApp(
            onGenerateRoute: (settings) {
              var name = settings.name.toString();
              print('settings:' + name);
              name = name.replaceAll('/?', '');

              List<String> params = name.split("&");

              for (final param in params) {
                print('param:' + param.toString());
                if (param.contains("appName=")) {
                  globals.appName = param.split("=")[1];
                } else if (param.contains("baseUrl=")) {
                  var baseUrl = param.split("=")[1];
                  globals.baseUrl = Uri.decodeFull(baseUrl);
                } else if (param.contains("language=")) {
                  globals.language = param.split("=")[1];
                } else if (param.contains("username=")) {
                  globals.username = param.split("=")[1];
                } else if (param.contains("password=")) {
                  globals.password = param.split("=")[1];
                } else if (param.contains("mobileOnly=")) {
                  globals.mobileOnly = param.split("=")[1] == 'true';
                } else if (param.contains("webOnly=")) {
                  globals.webOnly = param.split("=")[1] == 'true';
                }
              }

              if (params.length > 0) {
                SharedPreferencesHelper().setData(globals.appName,
                    globals.baseUrl, globals.language, globals.uploadPicWidth);
                SharedPreferencesHelper()
                    .setLoginData(globals.username, globals.password);
                if (globals.mobileOnly != null) {
                  SharedPreferencesHelper().setMobileOnly(globals.mobileOnly);
                }
              }

              switch (settings.name) {
                case '/menu':
                  MenuArguments menuArguments = settings.arguments;
                  return MaterialPageRoute(
                      builder: (_) => MenuPage(
                            listMenuItemsInDrawer:
                                menuArguments.listMenuItemsInDrawer,
                            menuItems: menuArguments.menuItems,
                            welcomeResponse: menuArguments.welcomeResponse,
                          ));
                case '/screen':
                  ScreenArguments screenArguments = settings.arguments;
                  return MaterialPageRoute(
                      builder: (_) => OpenScreenPage(
                            componentId: screenArguments.componentId,
                            items: screenArguments.items,
                            menuComponentId: screenArguments.menuComponentId,
                            request: screenArguments.request,
                            responseData: screenArguments.responseData,
                            templateName: screenArguments.templateName,
                            title: screenArguments.title,
                          ));
              }

              return null;
            },
            title: globals.appName ?? 'JVx Mobile',
            theme: theme,
            debugShowCheckedModeBanner: false,
            showPerformanceOverlay: false,
            //home: StartupPage(),
            localizationsDelegates: [
              const TranslationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale("en", "US"),
              const Locale("de", "DE")
            ],
            initialRoute: '/',
            routes: {
              '/': (context) => StartupPage(
                    this.loadConf,
                    config: this.config,
                  ),
              '/settings': (context) => SettingsPage(),
            },
          ));

  @override
  Widget build(BuildContext context) {
    return materialApp(context, this.theme);
  }
}
