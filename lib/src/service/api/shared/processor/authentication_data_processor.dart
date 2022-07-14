import '../../../../model/api/response/api_authentication_data_response.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/config/save_auth_key_command.dart';
import '../i_response_processor.dart';

class AuthenticationDataProcessor extends IResponseProcessor<ApiAuthenticationDataResponse> {
  @override
  List<BaseCommand> processResponse({required ApiAuthenticationDataResponse pResponse}) {
    SaveAuthKeyCommand saveAuthKeyCommand = SaveAuthKeyCommand(
      authKey: pResponse.authKey,
      reason: "Auth key from server ",
    );
    return [saveAuthKeyCommand];
  }
}
