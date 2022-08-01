import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/api/set_api_config_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

class SetApiConfigCommandProcessor
    with ConfigServiceGetterMixin, ApiServiceGetterMixin
    implements ICommandProcessor<SetApiConfigCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SetApiConfigCommand command) async {
    getApiService().setApiConfig(apiConfig: command.apiConfig);

    return [];
  }
}
