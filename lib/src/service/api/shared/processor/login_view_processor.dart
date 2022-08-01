import '../../../../model/api/api_object_property.dart';
import '../../../../model/api/request/api_login_request.dart';
import '../../../../model/api/response/login_view_response.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/ui/route_to_login_command.dart';
import '../i_response_processor.dart';

class LoginViewProcessor implements IResponseProcessor<LoginViewResponse> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BaseCommand> processResponse({required LoginViewResponse pResponse}) {
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
