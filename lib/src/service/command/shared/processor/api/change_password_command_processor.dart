import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/api/requests/api_change_password_request.dart';
import '../../../../../model/command/api/change_password_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

class ChangePasswordCommandProcessor
    with ApiServiceGetterMixin, ConfigServiceGetterMixin
    implements ICommandProcessor<ChangePasswordCommand> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(ChangePasswordCommand command) async {
    String? clientId = getConfigService().getClientId();

    if (clientId != null) {
      ApiChangePasswordRequest changePasswordRequest = ApiChangePasswordRequest(
        clientId: clientId,
        password: command.password,
        newPassword: command.newPassword,
        username: command.username,
      );
      return getApiService().sendRequest(request: changePasswordRequest);
    }
    return [];
  }
}
