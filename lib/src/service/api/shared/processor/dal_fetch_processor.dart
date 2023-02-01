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

import '../../../../flutter_ui.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/data/save_fetch_data_command.dart';
import '../../../../model/request/api_fetch_request.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/dal_fetch_response.dart';
import '../i_response_processor.dart';

class DalFetchProcessor extends IResponseProcessor<DalFetchResponse> {
  @override
  List<BaseCommand> processResponse(DalFetchResponse pResponse, ApiRequest? pRequest) {
    SaveFetchDataCommand saveFetchDataCommand = SaveFetchDataCommand(
        response: pResponse, reason: "Server sent FetchData", pageKey: cast<ApiFetchRequest>(pRequest)?.pageKey);

    return [saveFetchDataCommand];
  }
}
