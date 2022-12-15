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
import '../../../../model/command/ui/view/message/open_server_error_dialog_command.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/view/message/error_view_response.dart';
import '../i_response_processor.dart';

class ErrorViewProcessor implements IResponseProcessor<ErrorViewResponse> {
  @override
  List<BaseCommand> processResponse(ErrorViewResponse pResponse, ApiRequest? pRequest) {
    if (!pResponse.silentAbort) {
      return [
        OpenServerErrorDialogCommand(
          reason: "Server sent error in response",
          componentId: pResponse.componentId,
          title: pResponse.title,
          message: pResponse.message,
          userError: isUserError(pResponse.message!),
        )
      ];
    }
    return [];
  }

  /// Dirty error message check
  isUserError(String message) {
    if (message.toLowerCase().startsWith("invalid application:")) {
      return true;
    }
    return false;
  }
}
