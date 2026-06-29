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

import '../../../../model/command/api/fetch_command.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/data/delete_provider_data_command.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/dal_data_provider_changed_response.dart';
import '../../../data/i_data_service.dart';
import '../../../ui/i_ui_service.dart';
import '../i_response_processor.dart';

class DalDataProviderChangedProcessor extends IResponseProcessor<DalDataProviderChangedResponse> {
  @override
  Future<List<BaseCommand>> processResponse(DalDataProviderChangedResponse response, ApiRequest? request) async {
    List<BaseCommand> commands = [];

    IDataService servData = IDataService();

    // If -1 then delete all saved data and re-fetch
    if (response.reload == -1) {
      commands.add(DeleteProviderDataCommand(
        dataProvider: response.dataProvider,
        reason: "Data provider changed response was reload -1",
        deleteAll: true,
      ));

      bool hasMetaData = servData.getMetaData(response.dataProvider) != null;

      IUiService servUi = IUiService();

      if (hasMetaData && servData.updateMetaDataChanged(response)) {
        servUi.notifyMetaDataChange(response.dataProvider);
      }

      servUi.notifySubscriptionsOfReload(response.dataProvider);

      commands.add(
        FetchCommand(
          reason: "Data provider changed response was reload -1",
          fromRow: 0,
          rowCount: servUi.getSubscriptionRowCount(response.dataProvider),
          dataProvider: response.dataProvider,
          //if no metadata available -> include it with next fetch
          includeMetaData: !hasMetaData,
        ),
      );
    } else {
      IUiService? servUi;

      if (servData.updateMetaDataChanged(response)) {
        servUi ??= IUiService();
        servUi.notifyMetaDataChange(response.dataProvider);
      }
      bool dataChanged = await servData.updateDataChanged(response);
      bool selectionChanged = servData.updateSelectionChanged(response);

      if (dataChanged) {
        servUi ??= IUiService();
        servUi.notifyDataChange(dataProvider: response.dataProvider);
      } else if (selectionChanged) {
        servUi ??= IUiService();
        servUi.notifySelectionChange(response.dataProvider);
      }

      if (response.reload != null) {
        // If reload not -1/null re-fetch only given row
        FetchCommand fetchCommand = FetchCommand(
          reason: "Data provider changed response was reload ${response.reload!} row",
          fromRow: response.reload!,
          rowCount: 1,
          dataProvider: response.dataProvider,
        );
        commands.add(fetchCommand);
      }
    }

    return commands;
  }
}
