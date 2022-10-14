import '../../../../../model/command/api/set_value_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_set_value_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class SetValueCommandProcessor implements ICommandProcessor<SetValueCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SetValueCommand command) {
    return IApiService().sendRequest(
      ApiSetValueRequest(
        componentName: command.componentName,
        value: command.value,
      ),
    );
  }
}
