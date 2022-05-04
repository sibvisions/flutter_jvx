import 'package:flutter_client/src/mixin/ui_service_getter_mixin.dart';
import 'package:flutter_client/src/model/data/chunk/chunk_data.dart';

import '../../../../../mixin/data_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/get_data_chunk_command.dart';
import '../../i_command_processor.dart';

class GetDataChunkCommandProcessor with DataServiceMixin, UiServiceGetterMixin implements ICommandProcessor<GetDataChunkCommand> {
  @override
  Future<List<BaseCommand>> processCommand(GetDataChunkCommand command) async {
    ChunkData chunkData = await dataService.getDataChunk(
      pColumnNames: command.dataColumns,
      pFrom: command.from,
      pTo: command.to,
      pDataProvider: command.dataProvider,
    );

    getUiService().setChunkData(
      pChunkData: chunkData,
      pId: command.componentId,
      pDataProvider: command.dataProvider,
    );

    return [];
  }
}
