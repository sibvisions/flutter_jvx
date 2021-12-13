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
      return apiService.login(command.userName, command.password, clientId);
    } else {
      throw Exception("NO ClIENT ID FOUND, while trying to send login Request");
    }
  }
}
