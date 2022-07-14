import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_user_data_command.dart';
import '../../i_command_processor.dart';

class SaveUserDataCommandProcessor with ConfigServiceMixin implements ICommandProcessor<SaveUserDataCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveUserDataCommand command) async {
    configService.setUserInfo(command.userInfo);

    return [];
  }
}
