/* 
 * Copyright 2023 SIB Visions GmbH
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

import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../model/command/base_command.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/show_document_response.dart';
import '../i_response_processor.dart';

class ShowDocumentProcessor implements IResponseProcessor<ShowDocumentResponse> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BaseCommand> processResponse(ShowDocumentResponse pResponse, ApiRequest? pRequest) {
    String url = pResponse.url;

    if (url.isNotEmpty) {
      List<String> splitUrl;
      if (url.startsWith("\"")) {
        url = url.substring(1);
        splitUrl = url.substring(url.indexOf("\"")).split(";");
        url = url.substring(0, url.indexOf("\""));
      } else {
        splitUrl = url.split(';');
        url = splitUrl.first;
      }

      Uri? uri = Uri.tryParse(url);

      if (uri != null) {
        launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          webOnlyWindowName: splitUrl.length > 2 ? splitUrl[2] : null,
        );
      } else {
        launchUrlString(
          url,
          mode: LaunchMode.externalApplication,
          webOnlyWindowName: splitUrl.length > 2 ? splitUrl[2] : null,
        );
      }
    }

    return [];
  }
}
