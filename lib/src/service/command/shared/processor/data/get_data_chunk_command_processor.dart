import '../../../../../../services.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/get_data_chunk_command.dart';
import '../../../../../model/data/subscriptions/data_chunk.dart';
import '../../../../../model/request/api_fetch_request.dart';
import '../../i_command_processor.dart';

class GetDataChunkCommandProcessor implements ICommandProcessor<GetDataChunkCommand> {
  @override
  Future<List<BaseCommand>> processCommand(GetDataChunkCommand command) async {
    bool needFetch = await IDataService().checkIfFetchPossible(
      pFrom: command.from,
      pTo: command.to,
      pDataProvider: command.dataProvider,
    );

    if (!needFetch) {
      DataChunk dataChunk = await IDataService().getDataChunk(
        pColumnNames: command.dataColumns,
        pFrom: command.from,
        pTo: command.to,
        pDataProvider: command.dataProvider,
      );
      dataChunk.update = command.isUpdate;

      IUiService().setChunkData(
        pDataChunk: dataChunk,
        pDataProvider: command.dataProvider,
        pSubId: command.subId,
      );
      return [];
    }

    return IApiService().sendRequest(
      request: ApiFetchRequest(
        dataProvider: command.dataProvider,
        fromRow: command.from,
        rowCount: command.to != null ? command.to! - command.from : -1,
      ),
    );
  }
}
