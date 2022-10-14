import '../../../../model/command/base_command.dart';
import '../../../../model/command/config/save_auth_key_command.dart';
import '../../../../model/request/i_api_request.dart';
import '../../../../model/response/authentication_data_response.dart';
import '../i_response_processor.dart';

class AuthenticationDataProcessor extends IResponseProcessor<AuthenticationDataResponse> {
  @override
  List<BaseCommand> processResponse(AuthenticationDataResponse pResponse, IApiRequest? pRequest) {
    SaveAuthKeyCommand saveAuthKeyCommand = SaveAuthKeyCommand(
      authKey: pResponse.authKey,
      reason: "Auth key from server ",
    );
    return [saveAuthKeyCommand];
  }
}
