import '../../../../../../mixin/api_service_mixin.dart';
import '../../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/api/reload_menu_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_reload_menu_request.dart';
import '../../i_command_processor.dart';

class ReloadMenuCommandProcessor
    with ApiServiceGetterMixin, ConfigServiceGetterMixin
    implements ICommandProcessor<ReloadMenuCommand> {
  @override
  Future<List<BaseCommand>> processCommand(ReloadMenuCommand command) async {
    String? clientId = getConfigService().getClientId();
    if (clientId != null) {
      ApiReloadMenuRequest openMenuRequest = ApiReloadMenuRequest(clientId: clientId);
      return getApiService().sendRequest(request: openMenuRequest);
    } else {
      throw Exception("NO CLIENT ID FOUND, while trying to send openMenu request. CommandID: ${command.id}");
    }
  }
}
