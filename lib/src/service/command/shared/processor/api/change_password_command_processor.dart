import '../../../../../model/command/api/change_password_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_change_password_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class ChangePasswordCommandProcessor implements ICommandProcessor<ChangePasswordCommand> {
  @override
  Future<List<BaseCommand>> processCommand(ChangePasswordCommand command) {
    return IApiService().sendRequest(
        request: ApiChangePasswordRequest(
      password: command.password,
      newPassword: command.newPassword,
      username: command.username,
    ));
  }
}
