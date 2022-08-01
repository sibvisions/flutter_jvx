import '../../../../../../mixin/api_service_mixin.dart';
import '../../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/api/close_tab_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_close_tab_request.dart';
import '../../i_command_processor.dart';

class CloseTabCommandProcessor
    with ApiServiceGetterMixin, ConfigServiceGetterMixin
    implements ICommandProcessor<CloseTabCommand> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(CloseTabCommand command) async {
    String? clientId = getConfigService().getClientId();

    if (clientId != null) {
      ApiCloseTabRequest closeTabRequest =
          ApiCloseTabRequest(index: command.index, componentName: command.componentName, clientId: clientId);
      return getApiService().sendRequest(request: closeTabRequest);
    }

    return [];
  }
}
