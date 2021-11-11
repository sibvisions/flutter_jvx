import 'package:flutter_jvx/src/models/api/i_processor.dart';
import 'package:flutter_jvx/src/models/api/responses/response_application_parameters.dart';
import 'package:flutter_jvx/src/models/events/routing/route_event.dart';
import 'package:flutter_jvx/src/routing/routing_options.dart';
import 'package:flutter_jvx/src/util/mixin/events/routing/on_routing_event.dart';

class ApplicationParameterProcessor with OnRoutingEvent implements IProcessor {

  @override
  void processResponse(json) {
    ResponseApplicationParameters applicationParameters = ResponseApplicationParameters.fromJson(json);

    //Order of ifs are important, higher priority routes are later to overwrite weaker ones.
    RouteEvent? routeEvent;

    //Route to Menu
    String? isAuthenticated = applicationParameters.authenticated;
    if(isAuthenticated != null) {
      if(isAuthenticated == "yes"){
        var event = RouteEvent(
            routeTo: RoutingOptions.menu,
            origin: this,
            reason: "Authentication set to $isAuthenticated in ApplicationParameters"
        );
        routeEvent = event;
      }
    }

    //Route to WorkScreen

    //to be able to promote local variable
    String? openScreen = applicationParameters.openScreen;
    if(openScreen != null) {
      var event = RouteEvent(
          routeTo: RoutingOptions.workScreen,
          origin: this,
          reason: "OpenScreen was set in ApplicationParameters, ScreenClassName: " + openScreen,
          workScreenClassname: openScreen
      );
      routeEvent= event;
    }


    if(routeEvent != null) {
      fireRoutingEvent(routeEvent);
    }
  }

}