import '../../../../../../mixin/api_service_mixin.dart';
import '../../../../../../mixin/config_service_mixin.dart';
import '../../../../../../mixin/data_service_mixin.dart';
import '../../../../../../mixin/ui_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/get_data_chunk_command.dart';
import '../../../../../model/data/subscriptions/data_chunk.dart';
import '../../../../../model/request/api_fetch_request.dart';
import '../../i_command_processor.dart';

class GetDataChunkCommandProcessor
    with DataServiceGetterMixin, UiServiceGetterMixin, ApiServiceGetterMixin, ConfigServiceGetterMixin
    implements ICommandProcessor<GetDataChunkCommand> {
  @override
  Future<List<BaseCommand>> processCommand(GetDataChunkCommand command) async {
    bool needFetch = await getDataService().checkIfFetchPossible(
      pFrom: command.from,
      pTo: command.to,
      pDataProvider: command.dataProvider,
    );

    if (!needFetch) {
      DataChunk dataChunk = await getDataService().getDataChunk(
        pColumnNames: command.dataColumns,
        pFrom: command.from,
        pTo: command.to,
        pDataProvider: command.dataProvider,
      );
      dataChunk.update = command.isUpdate;

      getUiService().setChunkData(
        pDataChunk: dataChunk,
        pDataProvider: command.dataProvider,
        pSubId: command.subId,
      );
      return [];
    }

    ApiFetchRequest request = ApiFetchRequest(
      dataProvider: command.dataProvider,
      clientId: getConfigService().getClientId()!,
      fromRow: command.from,
      rowCount: command.to != null ? command.to! - command.from : -1,
    );

    List<BaseCommand> commands = await getApiService().sendRequest(request: request);

    return commands;
  }
}
