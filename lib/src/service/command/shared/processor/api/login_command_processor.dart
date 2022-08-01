import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/request/api_login_request.dart';
import '../../../../../model/command/api/login_command.dart';
import '../../../../../model/command/api/startup_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

class LoginCommandProcessor
    with ApiServiceGetterMixin, ConfigServiceGetterMixin
    implements ICommandProcessor<LoginCommand> {
  @override
  Future<List<BaseCommand>> processCommand(LoginCommand command) async {
    String? clientId = getConfigService().getClientId();

    if (clientId != null) {
      await getConfigService().setUsername(command.userName);
      await getConfigService().setPassword(command.password);

      ApiLoginRequest loginRequest = ApiLoginRequest(
        createAuthKey: command.createAuthKey,
        loginMode: command.loginMode,
        newPassword: command.newPassword,
        username: command.userName,
        password: command.password,
        clientId: clientId,
      );
      return getApiService().sendRequest(request: loginRequest);
    } else {
      return [StartupCommand(reason: "Login failed")];
    }
  }
}
