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

import '../../../../model/command/base_command.dart';
import '../../../../model/command/data/save_fetch_data_command.dart';
import '../../../../model/data/data_book.dart';
import '../../../../model/request/api_fetch_request.dart';
import '../../../../model/request/api_reload_data_request.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/request/api_set_values_request.dart';
import '../../../../model/request/filter.dart';
import '../../../../model/response/dal_fetch_response.dart';
import '../../../data/i_data_service.dart';
import '../i_response_processor.dart';

class DalFetchProcessor extends IResponseProcessor<DalFetchResponse> {
  @override
  List<BaseCommand> processResponse(DalFetchResponse response, ApiRequest? request) {
    bool setRootKey = false;
    Filter filter = const Filter.empty();

    List<bool> changedBySetValues = List.filled(response.columnNames.length, false);

    if (request is ApiFetchRequest) {
      filter = request.filter ?? filter;
      setRootKey = request.command?.setRootKey ?? setRootKey;
    } else if (request is ApiReloadDataRequest) {
      filter = request.filter ?? filter;
      setRootKey = request.command?.setRootKey ?? setRootKey;
    } else if (request is ApiSetValuesRequest) {
      filter = request.filter ?? filter;

      //only 1 record in response -> check changed
      if (response.from >= 0 && response.from == response.to) {
        DataBook? book = IDataService().getDataBook(response.dataProvider);

        if (book != null) {
          for (int i = 0; i < request.columnNames.length; i++) {
            int pos = response.columnNames.indexOf(request.columnNames[i]);

            if (pos > 0) {
              //mark column as changed by setValues
              changedBySetValues[pos] = true;
            }
          }
        }
      }
    }

    return [SaveFetchDataCommand(
      response: response,
      reason: "Server sent FetchData",
      requestFilter: filter,
      setRootKey: setRootKey,
      changed: changedBySetValues
    )];
  }
}
