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

import 'dart:convert';

import '../../../../model/command/base_command.dart';
import '../../../../model/command/config/save_application_style_command.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/download_style_response.dart';
import '../i_response_processor.dart';

class DownloadStyleProcessor extends IResponseProcessor<DownloadStyleResponse> {
  @override
  List<BaseCommand> processResponse(DownloadStyleResponse pResponse, ApiRequest? pRequest) {
    String decoded = utf8.decode(pResponse.bodyBytes);

    Map<String, dynamic> styleWithNull = jsonDecode(decoded);

    styleWithNull.removeWhere((key, value) => value == null);

    Map<String, String> styleNoNull = rebuildStylesMap(styleWithNull);

    return [
      SaveApplicationStyleCommand(style: styleNoNull, reason: "Downloaded Styles"),
    ];
  }

  Map<String, String> rebuildStylesMap(Map<String, dynamic> pOgMap, [String? pKeyPrefix]) {
    Map<String, String> rebuiltMap = {};

    pOgMap.forEach((key, value) {
      if (value is Map) {
        rebuiltMap
            .addAll(rebuildStylesMap(value as Map<String, dynamic>, pKeyPrefix == null ? key : "$pKeyPrefix.$key"));
      } else if (pKeyPrefix != null) {
        rebuiltMap["$pKeyPrefix.$key"] = value;
      } else {
        rebuiltMap[key] = value;
      }
    });

    return rebuiltMap;
  }
}
