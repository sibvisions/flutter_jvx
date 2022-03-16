
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'init_app_mobile.dart';
import 'init_app_web.dart';
import 'src/routing/app_delegate.dart';
import 'src/routing/app_information_parser.dart';

void main() {

  if (kIsWeb) {
    initAppWeb();
    runApp(MyApp());
  } else {
    initAppMobile().then((value) => runApp(MyApp()));
  }
}

ThemeData themeData = ThemeData.from(colorScheme: ColorScheme.light(
  primary: Colors.amber,
  background: Colors.grey.shade300

));

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final AppInformationParser _parser = AppInformationParser();
  final AppDelegate _delegate = AppDelegate();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return MaterialApp.router(
      theme: themeData,
      routeInformationParser: _parser,
      routerDelegate: _delegate,
      title: "Flutter Demo",
    );
  }
}
