import '../../../../../../mixin/services.dart';
import '../../../../../model/command/api/set_value_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_set_value_request.dart';
import '../../i_command_processor.dart';

class SetValueCommandProcessor with ApiServiceMixin implements ICommandProcessor<SetValueCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SetValueCommand command) {
    return getApiService().sendRequest(
      request: ApiSetValueRequest(
        componentName: command.componentName,
        value: command.value,
      ),
    );
  }
}
