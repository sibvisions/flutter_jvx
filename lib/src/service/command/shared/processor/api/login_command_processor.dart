import '../../../../../../services.dart';
import '../../../../../model/command/api/login_command.dart';
import '../../../../../model/command/api/startup_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_login_request.dart';
import '../../i_command_processor.dart';

class LoginCommandProcessor implements ICommandProcessor<LoginCommand> {
  @override
  Future<List<BaseCommand>> processCommand(LoginCommand command) async {
    String? clientId = IConfigService().getClientId();

    if (clientId != null) {
      await IConfigService().setUsername(command.userName);
      await IConfigService().setPassword(command.password);

      ApiLoginRequest loginRequest = ApiLoginRequest(
        createAuthKey: command.createAuthKey,
        loginMode: command.loginMode,
        newPassword: command.newPassword,
        username: command.userName,
        password: command.password,
      );
      return IApiService().sendRequest(loginRequest);
    } else {
      return [StartupCommand(reason: "Login failed")];
    }
  }
}
