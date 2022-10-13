import '../../../../../../commands.dart';
import '../../../../../../services.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/data/subscriptions/data_chunk.dart';
import '../../i_command_processor.dart';

class GetDataChunkCommandProcessor implements ICommandProcessor<GetDataChunkCommand> {
  @override
  Future<List<BaseCommand>> processCommand(GetDataChunkCommand command) async {
    bool needFetch = await IDataService().checkIfFetchPossible(
      pFrom: command.from,
      pTo: command.to,
      pDataProvider: command.dataProvider,
    );

    if (needFetch) {
      return [
        FetchCommand(
          fromRow: command.from,
          rowCount: command.to != null ? command.to! - command.from : -1,
          dataProvider: command.dataProvider,
          reason: "Fetch for ${command.runtimeType}",
        )
      ];
    }

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
}
