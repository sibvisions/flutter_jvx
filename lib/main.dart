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

void main() {
  runApp(MyApp());
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

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final _routerDelegate = BeamerDelegate(
    initialPath: "/splash",
    locationBuilder: BeamerLocationBuilder(
      beamLocations: [
        SplashLocation(),
        LoginLocation(),
        MenuLocation(),
        SettingLocation(),
        WorkScreenLocation(),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return MaterialApp.router(
      theme: themeData,
      routeInformationParser: BeamerParser(),
      routerDelegate: _routerDelegate,
      backButtonDispatcher: FlBackButtonDispatcher(delegate: _routerDelegate),
      title: "Flutter Demo",
    );
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
