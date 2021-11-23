import 'package:flutter_client/src/model/api/response/application_parameter_response.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/ui/route_command.dart';
import 'package:flutter_client/src/routing/app_routing_options.dart';

import '../i_processor.dart';

class ApplicationParametersProcessor implements IProcessor {


  @override
  List<BaseCommand> processResponse(json) {
    List<BaseCommand> commands = [];
    ApplicationParametersResponse response = ApplicationParametersResponse.fromJson(json);

    String? authenticated = response.authenticated;
    RouteCommand? routeCommand;
    if(authenticated != null && authenticated == "yes"){
      routeCommand = RouteCommand(
          routeTo: AppRoutingOptions.menu,
          reason: "User is marked as authenticated -'yes' in an ApplicationParameterResponse."
      );
    }

    String? openScreen = response.openScreen;
    if(openScreen != null){
      routeCommand = RouteCommand(
          routeTo: AppRoutingOptions.workScreen,
          reason: "Open Screen was set in ApplicationParameterResponse",
          screenName: openScreen
      );
    }

    if(routeCommand != null){
      commands.add(routeCommand);
    }

    return commands;
  }

}