import '../../../../../../mixin/api_service_mixin.dart';
import '../../../../../model/command/api/delete_record_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_delete_record_request.dart';
import '../../i_command_processor.dart';

class DeleteRecordCommandProcessor extends ICommandProcessor<DeleteRecordCommand> with ApiServiceGetterMixin {
  @override
  Future<List<BaseCommand>> processCommand(DeleteRecordCommand command) {
    return getApiService().sendRequest(
      request: ApiDeleteRecordRequest(
        dataProvider: command.dataProvider,
        selectedRow: command.selectedRow,
        fetch: command.fetch,
        filter: command.filter,
        filterCondition: command.filterCondition,
      ),
    );
  }
}
