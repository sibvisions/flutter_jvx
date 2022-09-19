import '../../../../../model/command/api/insert_record_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_insert_record_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class InsertRecordCommandProcessor implements ICommandProcessor<InsertRecordCommand> {
  @override
  Future<List<BaseCommand>> processCommand(InsertRecordCommand command) {
    return IApiService().sendRequest(
      request: ApiInsertRecordRequest(
        dataProvider: command.dataProvider,
      ),
    );
  }
}
