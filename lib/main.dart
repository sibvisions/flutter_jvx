import 'dart:developer';
import 'dart:io';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_client/src/routing/fl_back_button_dispatcher.dart';
import 'package:flutter_client/src/routing/locations/login_location.dart';
import 'package:flutter_client/src/routing/locations/menu_location.dart';
import 'package:flutter_client/src/routing/locations/setting_location.dart';
import 'package:flutter_client/src/routing/locations/splash_location.dart';
import 'package:flutter_client/src/routing/locations/work_screen_location.dart';
import 'package:flutter_client/util/parse_util.dart';

void main() {
  runApp(const MyApp());
}

double opacityMenu = 1;
double opacitySideMenu = 1;

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
    WidgetsFlutterBinding.ensureInitialized();
    _routerDelegate = BeamerDelegate(
      initialPath: "/splash",
      locationBuilder: BeamerLocationBuilder(
        beamLocations: [
          SplashLocation(styleCallbacks: [changeStyle]),
          LoginLocation(),
          MenuLocation(),
          SettingLocation(),
          WorkScreenLocation(),
        ],
      ),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //_routerDelegate.setNewRoutePath(const RouteInformation(location: "/splash"));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return MaterialApp.router(
      theme: themeData,
      routeInformationParser: BeamerParser(),
      routerDelegate: _routerDelegate,
      backButtonDispatcher: FlBackButtonDispatcher(delegate: _routerDelegate),
      title: "Flutter Demo",
    );
  }

  void changeStyle(Map<String, String> styleMap) {
    log('hello');
    log(styleMap.toString());

    opacityMenu = double.parse(styleMap['opacity.menu'] ?? '1');
    opacitySideMenu = double.parse(styleMap['opacity.sidemenu'] ?? '1');

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

      MaterialColor newTemeColor = MaterialColor(styleColor.value, color);

      themeData = ThemeData.from(
          colorScheme: ColorScheme.fromSwatch(
        primarySwatch: newTemeColor,
        backgroundColor: Colors.grey.shade200,
      ));
    }
    setState(() {});
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    var httpclient = super.createHttpClient(context);
    httpclient.badCertificateCallback = ignoreSecure;
    return httpclient;
  }

  static bool ignoreSecure(X509Certificate cert, String host, int port) {
    return true;
  }
}
