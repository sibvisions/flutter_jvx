import '../../../../model/command/base_command.dart';
import '../../../../model/command/ui/route_to_login_command.dart';
import '../../../../model/request/api_login_request.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/login_view_response.dart';
import '../api_object_property.dart';
import '../i_response_processor.dart';

class LoginViewProcessor implements IResponseProcessor<LoginViewResponse> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BaseCommand> processResponse(LoginViewResponse pResponse, ApiRequest? pRequest) {
    Map<String, String?> loginProps = {
      ApiObjectProperty.username: pResponse.username,
    };

    if (pRequest is ApiLoginRequest) {
      loginProps[ApiObjectProperty.password] = pRequest.password;
    }

    RouteToLoginCommand routeToLoginCommand = RouteToLoginCommand(
      mode: pResponse.mode,
      reason: "Login as response",
      loginData: loginProps,
    );

    return [routeToLoginCommand];
  }
}
