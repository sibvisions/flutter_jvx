import '../../../../model/command/base_command.dart';
import '../../../../model/command/config/save_auth_key_command.dart';
import '../../../../model/response/authentication_data_response.dart';
import '../i_response_processor.dart';

class AuthenticationDataProcessor extends IResponseProcessor<AuthenticationDataResponse> {
  @override
  List<BaseCommand> processResponse({required AuthenticationDataResponse pResponse}) {
    SaveAuthKeyCommand saveAuthKeyCommand = SaveAuthKeyCommand(
      authKey: pResponse.authKey,
      reason: "Auth key from server ",
    );
    return [saveAuthKeyCommand];
  }
}
