import 'dart:developer';
import 'dart:io';

import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'src/routing/fl_back_button_dispatcher.dart';
import 'src/routing/locations/login_location.dart';
import 'src/routing/locations/menu_location.dart';
import 'src/routing/locations/settings_location.dart';
import 'src/routing/locations/splash_location.dart';
import 'src/routing/locations/work_screen_location.dart';
import 'util/parse_util.dart';

void main() {
  runApp(const MyApp());
}

//Mobile Style Properties
double opacityMenu = 1;
double opacitySideMenu = 1;
double opacityControls = 1;

ThemeData themeData = ThemeData.from(
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.amber,
    backgroundColor: Colors.grey.shade200,
  ),
  // const ColorScheme.light(
  //   primary: Colors.amber,
  //   background: Color(0xFFEEEEEE),
  //   onPrimary: Colors.black,
  // ),
);

Locale locale = const Locale.fromSubtags(languageCode: "en");

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  late BeamerDelegate _routerDelegate;

  @override
  void initState() {
    super.initState();

    _routerDelegate = BeamerDelegate(
      initialPath: "/splash",
      locationBuilder: BeamerLocationBuilder(
        beamLocations: [
          SplashLocation(styleCallbacks: [changeStyle], languageCallbacks: [changeLanguage]),
          LoginLocation(),
          MenuLocation(),
          SettingsLocation(),
          WorkScreenLocation(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //_routerDelegate.setNewRoutePath(const RouteInformation(location: "/splash"));

    return MaterialApp.router(
      theme: themeData,
      routeInformationParser: BeamerParser(),
      routerDelegate: _routerDelegate,
      backButtonDispatcher: FlBackButtonDispatcher(delegate: _routerDelegate),
      title: "Flutter Demo",
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
        Locale('de', ''), // German, no country code
        Locale('fr', ''), // French, no country code
      ],
      locale: locale,
    );
  }

  void changeStyle(Map<String, String> styleMap) {
    opacityMenu = double.parse(styleMap['opacity.menu'] ?? '1');
    opacitySideMenu = double.parse(styleMap['opacity.sidemenu'] ?? '1');
    opacityControls = double.parse(styleMap['opacity.controls'] ?? '1');

    Color? styleColor = ParseUtil.parseHexColor(styleMap['theme.color']);
    if (styleColor != null) {
      Map<int, Color> color = {
        50: Color.fromRGBO(styleColor.red, styleColor.green, styleColor.blue, 0.1),
        100: Color.fromRGBO(styleColor.red, styleColor.green, styleColor.blue, 0.2),
        200: Color.fromRGBO(styleColor.red, styleColor.green, styleColor.blue, 0.3),
        300: Color.fromRGBO(styleColor.red, styleColor.green, styleColor.blue, 0.4),
        400: Color.fromRGBO(styleColor.red, styleColor.green, styleColor.blue, 0.5),
        500: Color.fromRGBO(styleColor.red, styleColor.green, styleColor.blue, 0.6),
        600: Color.fromRGBO(styleColor.red, styleColor.green, styleColor.blue, 0.7),
        700: Color.fromRGBO(styleColor.red, styleColor.green, styleColor.blue, 0.8),
        800: Color.fromRGBO(styleColor.red, styleColor.green, styleColor.blue, 0.9),
        900: Color.fromRGBO(styleColor.red, styleColor.green, styleColor.blue, 1),
      };

      MaterialColor styleMaterialColor = MaterialColor(styleColor.value, color);

      themeData = ThemeData.from(
          colorScheme: ColorScheme.fromSwatch(
        primarySwatch: styleMaterialColor,
        backgroundColor: Colors.grey.shade200,
      ));
    }
    setState(() {});
  }

  void changeLanguage(String pLanguage) {
    locale = Locale.fromSubtags(languageCode: pLanguage);
    log("setLanguage");
    setState(() {});
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    var client = super.createHttpClient(context);
    client.connectionTimeout = const Duration(seconds: 10);
    if (!kIsWeb) {
      // Needed to avoid CORS issues
      // TODO find way to not do this
      client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    }
    return client;
  }
}
