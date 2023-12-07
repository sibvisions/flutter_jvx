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
import '../../../../model/command/ui/download_action_command.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/download_action_response.dart';
import '../i_response_processor.dart';

class DownloadActionProcessor implements IResponseProcessor<DownloadActionResponse> {
  @override
  List<BaseCommand> processResponse(DownloadActionResponse pResponse, ApiRequest? pRequest) {
    List<String> urlParamList = pResponse.url.split(";");

    String url = urlParamList.first;
    bool showFile = urlParamList.last == "SHOW_FILE";

    return [
      DownloadActionCommand(
        fileId: pResponse.fileId,
        fileName: pResponse.fileName,
        url: url,
        showFile: showFile,
        reason: "Upload from server",
      )
    ];
  }
}
