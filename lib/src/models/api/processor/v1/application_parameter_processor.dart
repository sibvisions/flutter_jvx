import 'package:flutter_jvx/src/models/api/action/processor_action.dart';
import 'package:flutter_jvx/src/models/api/action/route_action.dart';
import 'package:flutter_jvx/src/models/api/i_processor.dart';
import 'package:flutter_jvx/src/models/api/responses/response_application_parameters.dart';
import 'package:flutter_jvx/src/routing/routing_options.dart';

class ApplicationParameterProcessor implements IProcessor {

  @override
  List<ProcessorAction> processResponse(json) {
    List<ProcessorAction> actions = [];
    ResponseApplicationParameters applicationParameters = ResponseApplicationParameters.fromJson(json);



    //Authenticated is set
    String? isAuthenticated = applicationParameters.authenticated;
    if(isAuthenticated != null) {
      if(isAuthenticated == "yes"){
        RouteAction routeAction = RouteAction(priority: 10, routingOptions: RoutingOptions.menu);
        actions.add(routeAction);
      }
    }

    //OpenScreen is set
    String? openScreen = applicationParameters.openScreen;
    if(openScreen != null) {
      RouteAction routeAction = RouteAction(priority: 30, routingOptions: RoutingOptions.workScreen, workScreenName: openScreen);
      actions.add(routeAction);
    }
    return actions;
  }

}