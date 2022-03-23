import 'package:flutter_client/src/model/api/requests/api_login_request.dart';

import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/api/login_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

class LoginCommandProcessor with ApiServiceMixin, ConfigServiceMixin implements ICommandProcessor<LoginCommand> {
  @override
  Future<List<BaseCommand>> processCommand(LoginCommand command) {
    String? clientId = configService.getClientId();
    if (clientId != null) {
      ApiLoginRequest loginRequest = ApiLoginRequest(
          username: command.userName,
          password: command.password,
          clientId: clientId
      );

      return apiService.sendRequest(request: loginRequest);
    } else {
      throw Exception("NO ClIENT ID FOUND, while trying to send login Request");
    }
  }
}
