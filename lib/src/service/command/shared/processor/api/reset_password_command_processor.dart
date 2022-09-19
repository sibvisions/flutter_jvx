import '../../../../../model/command/api/reset_password_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_reset_password_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class ResetPasswordCommandProcessor implements ICommandProcessor<ResetPasswordCommand> {
  @override
  Future<List<BaseCommand>> processCommand(ResetPasswordCommand command) {
    return IApiService().sendRequest(
      request: ApiResetPasswordRequest(
        identifier: command.identifier,
      ),
    );
  }
}
