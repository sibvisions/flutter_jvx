import '../../../../../model/command/api/set_values_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_set_values_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class SetValuesCommandProcessor implements ICommandProcessor<SetValuesCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SetValuesCommand command) {
    return IApiService().sendRequest(
      ApiSetValuesRequest(
        componentId: command.componentId,
        dataProvider: command.dataProvider,
        columnNames: command.columnNames,
        values: command.values,
        filter: command.filter,
        filterCondition: command.filterCondition,
      ),
    );
  }
}
