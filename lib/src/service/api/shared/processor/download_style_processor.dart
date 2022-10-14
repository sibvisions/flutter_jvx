import 'dart:convert';

import '../../../../model/command/base_command.dart';
import '../../../../model/command/config/save_application_style_command.dart';
import '../../../../model/request/i_api_request.dart';
import '../../../../model/response/download_style_response.dart';
import '../i_response_processor.dart';

class DownloadStyleProcessor extends IResponseProcessor<DownloadStyleResponse> {
  @override
  List<BaseCommand> processResponse(DownloadStyleResponse pResponse, IApiRequest? pRequest) {
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
