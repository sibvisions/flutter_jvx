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
import '../../../../model/command/data/delete_row_command.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/dal_data_provider_changed_response.dart';
import '../../../data/i_data_service.dart';
import '../../../ui/i_ui_service.dart';
import '../i_response_processor.dart';

class DalDataProviderChangedProcessor extends IResponseProcessor<DalDataProviderChangedResponse> {
  @override
  List<BaseCommand> processResponse(DalDataProviderChangedResponse pResponse, ApiRequest? pRequest) {
    List<BaseCommand> commands = [];

    if (IDataService().updateMetaDataChangedRepsonse(pChangedResponse: pResponse)) {
      IUiService().notifyMetaDataChange(pDataProvider: pResponse.dataProvider);
    }

    bool dataChanged = IDataService().updateDataChangedResponse(pChangedResponse: pResponse);
    bool selectionChanged = IDataService().updateSelectionChangedResponse(pChangedResponse: pResponse);

    // If -1 then delete all saved data and re-fetch
    if (pResponse.reload == -1) {
      commands.add(DeleteProviderDataCommand(
        dataProvider: pResponse.dataProvider,
        reason: "Data provider changed response was reload -1",
        deleteAll: true,
      ));

      IUiService().notifySubscriptionsOfReload(pDataprovider: pResponse.dataProvider);

      commands.add(
        FetchCommand(
          reason: "Data provider changed response was reload -1",
          fromRow: 0,
          rowCount: IUiService().getSubscriptionRowcount(pDataProvider: pResponse.dataProvider),
          dataProvider: pResponse.dataProvider,
          includeMetaData: true,
        ),
      );
    } else if (pResponse.reload != null) {
      // If reload not -1/null re-fetch only given row
      FetchCommand fetchCommand = FetchCommand(
        reason: "Data provider changed response was reload -1",
        fromRow: pResponse.reload!,
        rowCount: 1,
        dataProvider: pResponse.dataProvider,
      );
      commands.add(fetchCommand);
    } else if (dataChanged) {
      IUiService().notifyDataChange(pDataProvider: pResponse.dataProvider);
    } else if (selectionChanged) {
      IUiService().notifySelectionChange(pDataProvider: pResponse.dataProvider);
    }

    if (pResponse.deletedRow != null) {
      DeleteRowCommand deleteRowCommand = DeleteRowCommand(
        dataProvider: pResponse.dataProvider,
        deletedRow: pResponse.deletedRow!,
        newSelectedRow: pResponse.selectedRow!,
        reason: "Data provider changed - server response",
      );
      commands.add(deleteRowCommand);
    }

    return commands;
  }
}
