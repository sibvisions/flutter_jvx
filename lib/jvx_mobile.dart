import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/ui/page/login_page.dart';
import 'package:jvx_mobile_v3/ui/page/settings_page.dart';
import 'package:jvx_mobile_v3/ui/page/startup_page.dart';
import 'package:jvx_mobile_v3/utils/translations.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class JvxMobile extends StatelessWidget {
  final materialApp = MaterialApp(
    title: globals.appName,
    theme: ThemeData(
      primaryColor: UIData.ui_kit_color_2,
      fontFamily: UIData.ralewayFont,
      primarySwatch: Colors.amber
    ),
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
      '/': (context) => StartupPage(),
      '/settings': (context) => SettingsPage(),
      '/login': (context) => LoginPage(),
    },
  );

  @override
  Widget build(BuildContext context) {
    return materialApp;
  }
}