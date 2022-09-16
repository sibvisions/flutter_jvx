import '../../../../../../mixin/services.dart';
import '../../../../../model/command/api/insert_record_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_insert_record_request.dart';
import '../../i_command_processor.dart';

class InsertRecordCommandProcessor with ApiServiceMixin implements ICommandProcessor<InsertRecordCommand> {
  @override
  Future<List<BaseCommand>> processCommand(InsertRecordCommand command) {
    return getApiService().sendRequest(
      request: ApiInsertRecordRequest(
        dataProvider: command.dataProvider,
      ),
    );
  }
}
