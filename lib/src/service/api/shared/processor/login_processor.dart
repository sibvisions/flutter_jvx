import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/api/requests/api_login_request.dart';
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
    Map<String, String?> loginProps = {
      ApiObjectProperty.username: pResponse.username,
    };

    Object request = pResponse.originalRequest;
    if (request is ApiLoginRequest) {
      loginProps[ApiObjectProperty.password] = request.password;
    }

    RouteToLoginCommand routeToLoginCommand = RouteToLoginCommand(
      mode: pResponse.mode,
      reason: "Login as response",
      loginData: loginProps,
    );

    return [routeToLoginCommand];
  }
}
