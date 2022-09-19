import '../../../../../model/command/api/set_api_config_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class SetApiConfigCommandProcessor implements ICommandProcessor<SetApiConfigCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SetApiConfigCommand command) async {
    IApiService().setApiConfig(apiConfig: command.apiConfig);

    return [];
  }
}
