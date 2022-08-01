import '../../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_auth_key_command.dart';
import '../../i_command_processor.dart';

class SaveAuthKeyCommandProcessor with ConfigServiceGetterMixin implements ICommandProcessor<SaveAuthKeyCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveAuthKeyCommand command) async {
    await getConfigService().setAuthCode(command.authKey);
    return [];
  }
}
