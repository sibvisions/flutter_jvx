import 'package:flutter_client/src/mixin/api_service_mixin.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/model/api/requests/api_reset_password_request.dart';
import 'package:flutter_client/src/model/command/api/reset_password_command.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/config/user/user_info.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class ResetPasswordCommandProcessor with ConfigServiceMixin, ApiServiceMixin implements ICommandProcessor<ResetPasswordCommand> {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(ResetPasswordCommand command)  {

    String? clientId = configService.getClientId();
    UserInfo? userInfo = configService.getUserInfo();
    if(clientId != null && userInfo != null){
      ApiResetPasswordRequest passwordRequest = ApiResetPasswordRequest(
          identifier: userInfo.userName,
          clientId: clientId
      );

      return apiService.sendRequest(request: passwordRequest);
    } else {
      throw Exception("No clientId found while trying to sent ResetPasswordRequest");
    }
  }

}