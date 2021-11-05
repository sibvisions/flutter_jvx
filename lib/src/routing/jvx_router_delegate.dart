import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jvx/src/masks/login/login.dart';
import 'package:flutter_jvx/src/masks/menu/menu.dart';
import 'package:flutter_jvx/src/models/events/routing/route_back_event.dart';
import 'package:flutter_jvx/src/models/events/routing/route_event.dart';
import 'package:flutter_jvx/src/routing/jvx_route_path.dart';
import 'package:flutter_jvx/src/routing/routing_options.dart';
import 'package:flutter_jvx/src/util/mixin/events/routing/on_routing_back_event.dart';
import 'package:flutter_jvx/src/util/mixin/events/routing/on_routing_event.dart';

class JVxRouterDelegate extends  RouterDelegate<JVxRoutePath>
  with ChangeNotifier, PopNavigatorRouterDelegateMixin, OnRoutingEvent, OnRoutingBackEvent {

  Page activePage = MaterialPage(child: Login());
  RoutingOptions activeRoute = RoutingOptions.login;


  ///This stack is called first before any routing changes are called;
  ///This is to facilitate screen specific Routes (Master->Detail; Tab changes in TabsetPanel
  List<Function> currentScreenStack = [];
  List<Function> screenStack = [];


  StreamSubscription? routeSubscription;

  JVxRouterDelegate(){
    routeSubscription = routeEventStream.listen(_routingEventReceived);
    routeBackEventStream.listen(_routingBackEventReceived);
  }

  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Future<void> setNewRoutePath(JVxRoutePath configuration) async {


  }

  @override
  Future<bool> popRoute() {
    if(activeRoute == RoutingOptions.login){
      return SynchronousFuture(false);
    }
    fireRoutingBackEvent(RouteBackEvent(origin: this, reason: "OS back button pressed"));


    return SynchronousFuture(true);
  }

  void _routingEventReceived(RouteEvent event) {
    if(activeRoute != event.routeTo){
      _routeTo(event.routeTo);
    }
  }

  void _routingBackEventReceived(RouteBackEvent event){
    if(activeRoute == RoutingOptions.menu){
      _routeTo(RoutingOptions.login);
    }
  }

  void _routeTo(RoutingOptions routeTo){
    RoutingOptions? newRoute;
    MaterialPage? newPage;
    if(routeTo == RoutingOptions.login){
      newRoute = RoutingOptions.login;
      newPage = MaterialPage(child: Login());
    } else if(routeTo == RoutingOptions.menu) {
      newRoute = RoutingOptions.menu;
      newPage = const MaterialPage(child: Menu());
    }
    if(newRoute != null && newPage != null){
      activeRoute = newRoute;
      activePage = newPage;
    } else {
      throw Exception("New Route can not be found!");
    }

    notifyListeners();
  }

  @override
  void dispose() {
    StreamSubscription? tempSub = routeSubscription;
    if(tempSub != null){
      tempSub.cancel();
    }
    super.dispose();
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