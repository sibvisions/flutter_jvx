import 'dart:io';

import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_client/src/routing/fl_back_button_dispatcher.dart';
import 'package:flutter_client/src/routing/locations/login_location.dart';
import 'package:flutter_client/src/routing/locations/menu_location.dart';
import 'package:flutter_client/src/routing/locations/setting_location.dart';
import 'package:flutter_client/src/routing/locations/work_sceen_location.dart';

import 'init_app_mobile.dart';
import 'init_app_web.dart';

void main() {
  if (kIsWeb) {
    initAppWeb();
    runApp(MyApp());
  } else {
    initAppMobile().then((value) => runApp(MyApp()));
  }
}

ThemeData themeData = ThemeData.from(
    colorScheme: const ColorScheme.light(
  primary: Colors.amber,
  background: Color(0xFFEEEEEE),
));

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final _routerDelegate = BeamerDelegate(
    initialPath: "/login",
    locationBuilder: BeamerLocationBuilder(
      beamLocations: [
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
