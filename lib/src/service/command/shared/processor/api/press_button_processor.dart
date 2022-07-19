import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/api/requests/api_press_button_request.dart';
import '../../../../../model/command/api/press_button_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

class PressButtonProcessor
    with ApiServiceGetterMixin, ConfigServiceGetterMixin
    implements ICommandProcessor<PressButtonCommand> {
  @override
  Future<List<BaseCommand>> processCommand(PressButtonCommand command) async {
    String? clientId = getConfigService().getClientId();

    if (clientId != null) {
      ApiPressButtonRequest pressButtonRequest =
          ApiPressButtonRequest(componentName: command.componentName, clientId: clientId);

      return getApiService().sendRequest(request: pressButtonRequest);
    } else {
      throw Exception("Cant find Client id, while trying to send PressButton request!");
    }
  }
}
