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

import '../../../../flutter_ui.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/ui/view/message/open_server_error_dialog_command.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/bad_client_response.dart';
import '../i_response_processor.dart';

class BadClientProcessor implements IResponseProcessor<BadClientResponse> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BaseCommand> processResponse(BadClientResponse pResponse, ApiRequest? pRequest) {
    FlutterUI.log.e(pResponse.info);
    return [
      OpenServerErrorDialogCommand(
        reason: "Server sent bad client in response",
        title: FlutterUI.translate("Invalid Server Version"),
        message: FlutterUI.translate("Server/Client Version mismatch. An Update is required!"),
        userError: true,
      )
    ];
  }
}
