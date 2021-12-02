import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'init_app_mobile.dart';
import 'src/routing/app_delegate.dart';
import 'src/routing/app_information_parser.dart';

import 'init_app_web.dart';

void main() {
  if(kIsWeb){
    initAppWeb();
    runApp(MyApp());
  } else {
    initAppMobile().then((value) =>
        runApp(MyApp()));
  }
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final AppInformationParser _parser = AppInformationParser();
  final AppDelegate _delegate = AppDelegate();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
          routeInformationParser: _parser,
          routerDelegate: _delegate,
        title: "Flutter Demo",
    );
  }
}