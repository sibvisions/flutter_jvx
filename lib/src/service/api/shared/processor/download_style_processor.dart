import 'dart:convert';

import '../../../../model/response/download_style_response.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/config/save_application_style_command.dart';
import '../i_response_processor.dart';

class DownloadStyleProcessor extends IResponseProcessor<DownloadStyleResponse> {
  @override
  List<BaseCommand> processResponse({required DownloadStyleResponse pResponse}) {
    String decoded = utf8.decode(pResponse.bodyBytes);

    Map<String, dynamic> styleWithNull = jsonDecode(decoded);

    styleWithNull.removeWhere((key, value) => value == null);

    Map<String, String> styleNoNull = {};

    styleWithNull.forEach((key, value) {
      if (value is Map) {
        value.forEach((internalKey, internalValue) {
          styleNoNull["$key.$internalKey"] = internalValue;
        });
      } else {
        styleNoNull[key] = value;
      }
    });

    return [
      SaveApplicationStyleCommand(style: styleNoNull, reason: "Downloaded Translations"),
    ];
  }
}
