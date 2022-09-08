import '../../../../../../mixin/api_service_mixin.dart';
import '../../../../../model/command/api/set_values_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_set_values_request.dart';
import '../../i_command_processor.dart';

class SetValuesCommandProcessor with ApiServiceGetterMixin implements ICommandProcessor<SetValuesCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SetValuesCommand command) {
    return getApiService().sendRequest(
      request: ApiSetValuesRequest(
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
