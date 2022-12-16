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

import '../../../../../flutter_jvx.dart';
import '../../../../model/response/dal_data_provider_changed_response.dart';
import '../i_response_processor.dart';

class DalDataProviderChangedProcessor extends IResponseProcessor<DalDataProviderChangedResponse> {
  @override
  List<BaseCommand> processResponse(DalDataProviderChangedResponse pResponse, ApiRequest? pRequest) {
    List<BaseCommand> commands = [];

    if (IDataService().updateMetaDataChanged(pChangedResponse: pResponse)) {
      IUiService().notifyMetaDataChange(pDataProvider: pResponse.dataProvider);
    }

    if (IDataService().updateDataChanged(pChangedResponse: pResponse)) {
      IUiService().notifyDataChange(pDataProvider: pResponse.dataProvider);
    }

    // If -1 then delete all saved data and re-fetch
    if (pResponse.reload == -1) {
      DeleteProviderDataCommand deleteProviderDataCommand = DeleteProviderDataCommand(
        dataProvider: pResponse.dataProvider,
        reason: "Data provider changed response was reload -1",
        deleteAll: true,
      );
      commands.add(deleteProviderDataCommand);

      FetchCommand fetchCommand = FetchCommand(
        reason: "Data provider changed response was reload -1",
        fromRow: 0,
        rowCount: 100,
        dataProvider: pResponse.dataProvider,
      );
      commands.add(fetchCommand);
    } else if (pResponse.reload != null) {
      // If reload not -1/null re-fetch only given row
      FetchCommand fetchCommand = FetchCommand(
        reason: "Data provider changed response was reload -1",
        fromRow: pResponse.reload!,
        rowCount: 1,
        dataProvider: pResponse.dataProvider,
      );
      commands.add(fetchCommand);
    }

    if (pResponse.deletedRow != null) {
      DeleteRowCommand deleteRowCommand = DeleteRowCommand(
        dataProvider: pResponse.dataProvider,
        deletedRow: pResponse.deletedRow!,
        newSelectedRow: pResponse.selectedRow!,
        reason: "Data provider changed - server response",
      );
      commands.add(deleteRowCommand);
    } else if (pResponse.selectedRow != null && pResponse.reload != -1) {
      ChangeSelectedRowCommand changeSelectedRowCommand = ChangeSelectedRowCommand(
        dataProvider: pResponse.dataProvider,
        newSelectedRow: pResponse.selectedRow!,
        reason: "Data provider changed - server response",
      );
      commands.add(changeSelectedRowCommand);
    }

    return commands;
  }
}
