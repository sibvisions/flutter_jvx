import '../../../../../model/command/api/filter_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_filter_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class FilterCommandProcessor implements ICommandProcessor<FilterCommand> {
  @override
  Future<List<BaseCommand>> processCommand(FilterCommand command) async {
    return IApiService().sendRequest(
      request: ApiFilterRequest(
        dataProvider: command.dataProvider,
        columnNames: command.columnNames,
        value: command.value,
        editorComponentId: command.editorId,
        filter: command.filter,
        filterCondition: command.filterCondition,
      ),
    );
  }
}
