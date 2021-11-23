
import 'app_routing_options.dart';

class AppRoutePath{
  final AppRoutingOptions page;
  final String? workScreen;


  AppRoutePath.login() :
        page = AppRoutingOptions.login,
        workScreen = null;

  AppRoutePath.menu() :
        page = AppRoutingOptions.menu,
        workScreen = null;

  AppRoutePath.screen({required this.workScreen}) :
        page = AppRoutingOptions.workScreen;

  AppRoutePath.settings() :
        page = AppRoutingOptions.settings,
        workScreen = null;
}