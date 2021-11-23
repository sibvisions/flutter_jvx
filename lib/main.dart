import 'package:flutter/material.dart';
import 'package:flutter_client/src/routing/app_delegate.dart';
import 'package:flutter_client/src/routing/app_information_parser.dart';

import 'init_app.dart';

void main() {
  initApp();
  runApp(MyApp());
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