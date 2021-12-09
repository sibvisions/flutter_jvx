
import 'app_routing_type.dart';

class AppRoutePath{
  final AppRoutingType page;
  final String? workScreen;


  AppRoutePath.login() :
        page = AppRoutingType.login,
        workScreen = null;

  AppRoutePath.menu() :
        page = AppRoutingType.menu,
        workScreen = null;

  AppRoutePath.screen({required this.workScreen}) :
        page = AppRoutingType.workScreen;

  AppRoutePath.settings() :
        page = AppRoutingType.settings,
        workScreen = null;
}