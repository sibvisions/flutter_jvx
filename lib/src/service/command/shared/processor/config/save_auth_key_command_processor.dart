import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_auth_key_command.dart';
import '../../../../config/i_config_service.dart';
import '../../i_command_processor.dart';

class SaveAuthKeyCommandProcessor implements ICommandProcessor<SaveAuthKeyCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveAuthKeyCommand command) async {
    await IConfigService().setAuthCode(command.authKey);
    return [];
  }
}
