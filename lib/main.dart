import 'package:flutter/material.dart';
import 'package:flutter_jvx/src/init_app.dart';
import 'package:flutter_jvx/src/masks/login/login.dart';
import 'package:flutter_jvx/src/routing/jvx_information_parser.dart';
import 'package:flutter_jvx/src/routing/jvx_router_delegate.dart';

void main() {
  initApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final JVxRouteInformationParser _parser = JVxRouteInformationParser();
  final JVxRouterDelegate _delegate = JVxRouterDelegate();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
          routeInformationParser: _parser,
          routerDelegate: _delegate,
        title: "Flutter Demo",
    );
  }
}