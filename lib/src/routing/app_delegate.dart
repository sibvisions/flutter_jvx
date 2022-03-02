import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../mask/camera/qr_scanner_mask.dart';
import '../mask/setting/settings_page.dart';
import '../model/routing/route_close_qr_scanner.dart';
import '../model/routing/route_open_qr_scanner.dart';
import '../model/routing/route_to_settings_page.dart';
import '../model/command/ui/route_command.dart';

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
class AppDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin, UiServiceMixin {
  List<Page> activePage = [MaterialPage(child: AppLogin())];
  AppRoutingType activeRoute = AppRoutingType.login;

  StreamSubscription? routeSubscription;

  AppDelegate() {
    routeSubscription = uiService.getRouteChangeStream().listen(_routeChanged);
  }

  _routeChanged(dynamic event) {
    if (event is RouteToMenu) {
      activePage = [
        MaterialPage(
            child: AppMenu(
          menuModel: event.menuModel,
        ))
      ];
      activeRoute = AppRoutingType.menu;
    } else if (event is RouteToWorkScreen) {
      activePage = [
        MaterialPage(
            child: WorkScreen(
          screen: event.screen,
          key: Key(event.screen.id + "_Work"),
        ))
      ];
      activeRoute = AppRoutingType.workScreen;
    } else if (event is RouteToSettingsPage) {
      activePage = [const MaterialPage(child: SettingsPage())];
      activeRoute = AppRoutingType.settings;
    } else if (event is RouteOpenRQScanner) {
      activePage.add(MaterialPage(child: QRScannerMask(callBack: event.callBack)));
    } else if (event is RouteCloseQRScanner) {
      activePage.removeLast();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    StreamSubscription? subscription = routeSubscription;
    if (subscription != null) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
  Future<bool> popRoute() {
    //don't close app if pressing back on login
    if (activePage.length == 2) {
      activePage.removeLast();
      notifyListeners();
      return SynchronousFuture(true);
    }

    if (activeRoute == AppRoutingType.login) {
      return SynchronousFuture(true);
    } else if (activeRoute == AppRoutingType.menu) {
      activePage = [MaterialPage(child: AppLogin())];
      activeRoute = AppRoutingType.login;
      notifyListeners();
    } else if (activeRoute == AppRoutingType.workScreen) {
      RouteCommand command = RouteCommand(routeType: AppRoutingType.menu, reason: "backButton");
      uiService.sendCommand(command);
    } else if (activeRoute == AppRoutingType.settings) {
      activePage = [MaterialPage(child: AppLogin())];
      activeRoute = AppRoutingType.login;
      notifyListeners();
    }

    return SynchronousFuture(true);
  }

  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) async {}

  @override
  Widget build(BuildContext context) {
    return (Navigator(
      key: navigatorKey,
      pages: [activePage.last],
      onPopPage: (route, result) {
        return route.didPop(result);
      },
    ));
  }
}
