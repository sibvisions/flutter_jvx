import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/request/api_set_value_request.dart';
import '../../../../../model/command/api/set_value_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

class SetValueCommandProcessor
    with ConfigServiceGetterMixin, ApiServiceGetterMixin
    implements ICommandProcessor<SetValueCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SetValueCommand command) {
    String? clientId = getConfigService().getClientId();

    if (clientId != null) {
      ApiSetValueRequest setValueRequest =
          ApiSetValueRequest(componentName: command.componentName, value: command.value, clientId: clientId);

      return getApiService().sendRequest(request: setValueRequest);
    } else {
      throw Exception("NO CLIENT ID FOUND, while trying to send setValue request. CommandID: " + command.id.toString());
    }
  }
}
