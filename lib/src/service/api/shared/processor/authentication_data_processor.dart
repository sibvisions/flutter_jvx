import 'package:flutter_client/src/model/api/response/api_authentication_data_response.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/api/shared/i_processor.dart';

import '../../../../model/command/config/save_auth_key_command.dart';

class AuthenticationDataProcessor extends IProcessor<ApiAuthenticationDataResponse> {
  @override
  List<BaseCommand> processResponse({required ApiAuthenticationDataResponse pResponse}) {
    SaveAuthKeyCommand saveAuthKeyCommand = SaveAuthKeyCommand(
      authKey: pResponse.authKey,
      reason: "Auth key from server ",
    );
    return [saveAuthKeyCommand];
  }
}
