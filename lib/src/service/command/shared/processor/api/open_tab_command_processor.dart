import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/api/requests/api_open_tab_request.dart';
import '../../../../../model/command/api/open_tab_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

class OpenTabCommandProcessor
    with ApiServiceGetterMixin, ConfigServiceGetterMixin
    implements ICommandProcessor<OpenTabCommand> {
  @override
  Future<List<BaseCommand>> processCommand(OpenTabCommand command) async {
    String? clientId = getConfigService().getClientId();

    if (clientId != null) {
      ApiOpenTabRequest openTabRequest =
          ApiOpenTabRequest(index: command.index, componentName: command.componentName, clientId: clientId);

      return getApiService().sendRequest(request: openTabRequest);
    }

    return [];
  }
}
