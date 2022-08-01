import '../../../../../../mixin/api_service_mixin.dart';
import '../../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/api/reset_password_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_reset_password_request.dart';
import '../../i_command_processor.dart';

class ResetPasswordCommandProcessor
    with ConfigServiceGetterMixin, ApiServiceGetterMixin
    implements ICommandProcessor<ResetPasswordCommand> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(ResetPasswordCommand command) {
    String? clientId = getConfigService().getClientId();

    if (clientId != null) {
      ApiResetPasswordRequest passwordRequest =
          ApiResetPasswordRequest(identifier: command.identifier, clientId: clientId);

      return getApiService().sendRequest(request: passwordRequest);
    } else {
      throw Exception("No clientId found while trying to sent ResetPasswordRequest");
    }
  }
}
