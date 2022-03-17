import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/api/open_tab_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

class OpenTabProcessor with ApiServiceMixin, ConfigServiceMixin implements ICommandProcessor<OpenTabCommand> {
  @override
  Future<List<BaseCommand>> processCommand(OpenTabCommand command) async {
    String? clientId = configService.getClientId();

    if (clientId != null) {
      return apiService.openTab(clientId: clientId, componentName: command.componentName, index: command.index);
    }

    return [];
  }
}
