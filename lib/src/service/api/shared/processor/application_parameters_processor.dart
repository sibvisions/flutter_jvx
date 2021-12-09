import 'package:flutter_client/src/routing/app_routing_type.dart';

import '../../../../model/api/response/application_parameter_response.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/ui/route_command.dart';
import '../../../../routing/app_routing_type.dart';

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
          routeType: AppRoutingType.menu,
          reason: "User is marked as authenticated -'yes' in an ApplicationParameterResponse."
      );
    }

    String? openScreen = response.openScreen;
    if(openScreen != null){
      routeCommand = RouteCommand(
          routeType: AppRoutingType.workScreen,
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