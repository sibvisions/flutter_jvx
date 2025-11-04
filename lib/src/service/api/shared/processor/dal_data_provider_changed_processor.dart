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

import '../../../../commands.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/dal_data_provider_changed_response.dart';
import '../../../data/i_data_service.dart';
import '../../../ui/i_ui_service.dart';
import '../i_response_processor.dart';

class DalDataProviderChangedProcessor extends IResponseProcessor<DalDataProviderChangedResponse> {
  @override
  List<BaseCommand> processResponse(DalDataProviderChangedResponse pResponse, ApiRequest? pRequest) {
    List<BaseCommand> commands = [];

    // If -1 then delete all saved data and re-fetch
    if (pResponse.reload == -1) {
      commands.add(DeleteProviderDataCommand(
        dataProvider: pResponse.dataProvider,
        reason: "Data provider changed response was reload -1",
        deleteAll: true,
      ));

      bool fetchMetaData = IDataService().getMetaData(pResponse.dataProvider) == null;

      if (!fetchMetaData) {
        if (IDataService().updateMetaDataChanged(pChangedResponse: pResponse)) {
          IUiService().notifyMetaDataChange(pResponse.dataProvider);
        }
      }

      IUiService().notifySubscriptionsOfReload(pResponse.dataProvider);

      commands.add(
        FetchCommand(
          reason: "Data provider changed response was reload -1",
          fromRow: 0,
          rowCount: IUiService().getSubscriptionRowCount(pResponse.dataProvider),
          dataProvider: pResponse.dataProvider,
          //if no metadata available -> include it with next fetch
          includeMetaData: fetchMetaData,
        ),
      );
    } else {
      if (IDataService().updateMetaDataChanged(pChangedResponse: pResponse)) {
        IUiService().notifyMetaDataChange(pResponse.dataProvider);
      }
      bool dataChanged = IDataService().updateDataChanged(pChangedResponse: pResponse);
      bool selectionChanged = IDataService().updateSelectionChanged(pChangedResponse: pResponse);

      if (dataChanged) {
        IUiService().notifyDataChange(pDataProvider: pResponse.dataProvider);
      } else if (selectionChanged) {
        IUiService().notifySelectionChange(pResponse.dataProvider);
      }

      if (pResponse.reload != null) {
        // If reload not -1/null re-fetch only given row
        FetchCommand fetchCommand = FetchCommand(
          reason: "Data provider changed response was reload ${pResponse.reload!} row",
          fromRow: pResponse.reload!,
          rowCount: 1,
          dataProvider: pResponse.dataProvider,
        );
        commands.add(fetchCommand);
      }
    }

    return commands;
  }
}
