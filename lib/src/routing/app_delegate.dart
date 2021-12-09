
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/command/ui/route_command.dart';

import '../mask/login/app_login.dart';
import '../mask/menu/app_menu.dart';
import '../mask/work_screen/work_screen.dart';
import '../mixin/ui_service_mixin.dart';
import '../model/routing/route_to_menu.dart';
import '../model/routing/route_to_work_screen.dart';
import 'app_route_path.dart';
import 'app_routing_type.dart';


///
/// Responsible for route Management of the app
///
class AppDelegate extends RouterDelegate<AppRoutePath> with ChangeNotifier, PopNavigatorRouterDelegateMixin, UiServiceMixin {
  Page activePage = MaterialPage(child: AppLogin());
  AppRoutingType activeRoute = AppRoutingType.login;

  StreamSubscription? routeSubscription;

  AppDelegate() {
    routeSubscription = uiService.getRouteChangeStream().listen(_routeChanged);
  }

  _routeChanged(dynamic event) {
    if(event is RouteToMenu){
      activePage = MaterialPage(child: AppMenu(menuModel: event.menuModel, uiService: uiService,));
      activeRoute = AppRoutingType.menu;
    } else if (event is RouteToWorkScreen) {
      activePage = MaterialPage(child: WorkScreen(screen: event.screen));
      activeRoute = AppRoutingType.workScreen;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    StreamSubscription? subscription = routeSubscription;
    if(subscription != null) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
  Future<bool> popRoute() {
    //don't close app if pressing back on login
    if(activeRoute == AppRoutingType.login){
      return SynchronousFuture(false);
    }
    //if OS Back pressed go back to Login
    if(activeRoute == AppRoutingType.menu){
      activePage = MaterialPage(child: AppLogin());
      activeRoute = AppRoutingType.menu;
      notifyListeners();
    }

    if(activeRoute == AppRoutingType.workScreen){
      RouteCommand command = RouteCommand(routeType: AppRoutingType.menu, reason: "backButton");
      uiService.sendCommand(command);
    }

    return SynchronousFuture(true);
  }



  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) async {

  }

  @override
  Widget build(BuildContext context) {
    return (
        Navigator(
          key: navigatorKey,
          pages: [activePage],
          onPopPage: (route, result) {
            return route.didPop(result);
          },
        )
    );
  }
}