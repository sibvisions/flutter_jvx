import '../../../../../../mixin/api_service_mixin.dart';
import '../../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/api/open_menu_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_menu_request.dart';
import '../../i_command_processor.dart';

class OpenMenuCommandProcessor
    with ApiServiceGetterMixin, ConfigServiceGetterMixin
    implements ICommandProcessor<OpenMenuCommand> {
  @override
  Future<List<BaseCommand>> processCommand(OpenMenuCommand command) async {
    String? clientId = getConfigService().getClientId();
    if (clientId != null) {
      ApiOpenMenuRequest openMenuRequest = ApiOpenMenuRequest(clientId: clientId);
      return getApiService().sendRequest(request: openMenuRequest);
    } else {
      throw Exception("NO CLIENT ID FOUND, while trying to send openMenu request. CommandID: ${command.id}");
    }
  }
}
