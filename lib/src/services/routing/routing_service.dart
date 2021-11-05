import 'package:flutter_jvx/src/models/events/meta/authentication_event.dart';
import 'package:flutter_jvx/src/models/events/routing/route_event.dart';
import 'package:flutter_jvx/src/routing/routing_options.dart';
import 'package:flutter_jvx/src/services/routing/i_routing_service.dart';
import 'package:flutter_jvx/src/util/mixin/events/meta/on_authentication_event.dart';
import 'package:flutter_jvx/src/util/mixin/events/routing/on_routing_event.dart';

class RoutingService with OnRoutingEvent, OnAuthenticationEvent implements IRoutingService {




  RoutingService() {
    authenticationEventStream.listen(onAuthentication);
  }



  void onAuthentication(AuthenticationEvent event) {
    RouteEvent routeEvent;
    if(event.authenticationStatus){
      routeEvent = RouteEvent(
        origin: this,
        reason: "User authenticated In Application parameters",
        routeTo: RoutingOptions.menu,
      );
    } else {
      routeEvent = RouteEvent(
        origin: this,
        reason: "User un-authenticated In Application parameters",
        routeTo: RoutingOptions.login,
      );
    }
    fireRoutingEvent(routeEvent);
  }

  @override
  void registerScreenCustomRoute(Function callback) {
    // TODO: implement registerScreenCustomRoute
  }

  @override
  void unRegisterScreenCustomRoute(Function callback) {
    // TODO: implement unRegisterScreenCustomRoute
  }

}