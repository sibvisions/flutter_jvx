/* 
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import '../../../../../model/command/api/fetch_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/get_data_chunk_command.dart';
import '../../../../../model/data/subscriptions/data_chunk.dart';
import '../../../../data/i_data_service.dart';
import '../../../../ui/i_ui_service.dart';
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
