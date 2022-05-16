import 'package:flutter_client/src/mixin/api_service_mixin.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/mixin/ui_service_getter_mixin.dart';
import 'package:flutter_client/src/model/api/requests/api_fetch_request.dart';
import 'package:flutter_client/src/model/data/subscriptions/data_chunk.dart';

import '../../../../../mixin/data_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/get_data_chunk_command.dart';
import '../../i_command_processor.dart';

class GetDataChunkCommandProcessor
    with DataServiceMixin, UiServiceGetterMixin, ApiServiceMixin, ConfigServiceMixin
    implements ICommandProcessor<GetDataChunkCommand> {
  @override
  Future<List<BaseCommand>> processCommand(GetDataChunkCommand command) async {
    bool needFetch = await dataService.checkIfFetchPossible(
      pFrom: command.from,
      pTo: command.to,
      pDataProvider: command.dataProvider,
    );

    if (!needFetch) {
      DataChunk dataChunk = await dataService.getDataChunk(
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
      clientId: configService.getClientId()!,
      fromRow: command.from,
      rowCount: command.to != null ? command.to! - command.from : -1,
    );

    List<BaseCommand> commands = await apiService.sendRequest(request: request);
    commands.add(command);

    return commands;
  }
}
