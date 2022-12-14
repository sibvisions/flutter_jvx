/* Copyright 2022 SIB Visions GmbH
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

import '../../../../../model/command/api/select_record_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/change_selected_row_command.dart';
import '../../../../../model/request/api_select_record_request.dart';
import '../../../../api/i_api_service.dart';
import '../../../../config/config_service.dart';
import '../../i_command_processor.dart';

class SelectRecordCommandProcessor implements ICommandProcessor<SelectRecordCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SelectRecordCommand command) async {
    if (ConfigService().isOffline()) {
      return [
        ChangeSelectedRowCommand(
            dataProvider: command.dataProvider, newSelectedRow: command.selectedRecord, reason: command.reason)
      ];
    }

    return IApiService().sendRequest(
      ApiSelectRecordRequest(
        dataProvider: command.dataProvider,
        selectedRow: command.selectedRecord,
        fetch: command.fetch,
        filter: command.filter,
        reload: command.reload,
      ),
    );
  }
}
