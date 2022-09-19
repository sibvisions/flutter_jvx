import '../../../../../model/command/api/fetch_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_fetch_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class FetchCommandProcessor extends ICommandProcessor<FetchCommand> {
  @override
  Future<List<BaseCommand>> processCommand(FetchCommand command) {
    return IApiService().sendRequest(
      request: ApiFetchRequest(
        dataProvider: command.dataProvider,
        fromRow: command.fromRow,
        rowCount: command.rowCount,
        columnNames: command.columnNames,
        includeMetaData: command.includeMetaData,
      ),
    );
  }
}
