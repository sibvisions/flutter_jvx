import 'package:flutter_client/src/model/api/response/login_response.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/ui/route_to_login_command.dart';
import 'package:flutter_client/src/service/api/shared/i_processor.dart';

class LoginProcessor implements IProcessor<LoginResponse> {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BaseCommand> processResponse({required LoginResponse pResponse}) {

    RouteToLoginCommand routeToLoginCommand = RouteToLoginCommand(
        reason: "Login as response"
    );

    return [routeToLoginCommand];
  }

}