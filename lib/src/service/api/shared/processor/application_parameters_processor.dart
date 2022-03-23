import '../../../../model/api/response/application_parameter_response.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/ui/route_command.dart';
import '../../../../routing/app_routing_type.dart';
import '../i_processor.dart';

class ApplicationParametersProcessor implements IProcessor<ApplicationParametersResponse> {
  @override
  List<BaseCommand> processResponse({required ApplicationParametersResponse pResponse}) {
    List<BaseCommand> commands = [];
    ApplicationParametersResponse response = pResponse;

    String? authenticated = response.authenticated;
    RouteCommand? routeCommand;


    String? openScreen = response.openScreen;
    if (openScreen != null) {
      routeCommand = RouteCommand(
          routeType: AppRoutingType.workScreen,
          reason: "Open Screen was set in ApplicationParameterResponse",
          screenName: openScreen);
    }

    if (routeCommand != null) {
      commands.add(routeCommand);
    }

    return commands;
  }
}
