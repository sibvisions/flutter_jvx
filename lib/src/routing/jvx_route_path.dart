import 'package:flutter_jvx/src/routing/routing_options.dart';

class JVxRoutePath{
  final RoutingOptions page;
  final String? workScreen;


  JVxRoutePath.login() :
    page = RoutingOptions.login,
    workScreen = null;

  JVxRoutePath.menu() :
    page = RoutingOptions.menu,
    workScreen = null;

  JVxRoutePath.screen({required this.workScreen}) :
    page = RoutingOptions.workScreen;

  JVxRoutePath.settings() :
    page = RoutingOptions.settings,
    workScreen = null;
}