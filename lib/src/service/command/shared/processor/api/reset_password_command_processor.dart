import '../../../../../../mixin/api_service_mixin.dart';
import '../../../../../model/command/api/reset_password_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_reset_password_request.dart';
import '../../i_command_processor.dart';

class ResetPasswordCommandProcessor with ApiServiceGetterMixin implements ICommandProcessor<ResetPasswordCommand> {
  @override
  Future<List<BaseCommand>> processCommand(ResetPasswordCommand command) {
    return getApiService().sendRequest(
      request: ApiResetPasswordRequest(
        identifier: command.identifier,
      ),
    );
  }
}
