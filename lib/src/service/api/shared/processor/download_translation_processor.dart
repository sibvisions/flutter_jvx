import 'package:archive/archive.dart';
import 'package:flutter_client/src/model/api/response/download_translation_response.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/config/save_application_translation_command.dart';
import 'package:flutter_client/src/service/api/shared/i_processor.dart';

class DownloadTranslationProcessor implements IProcessor<DownloadTranslationResponse> {
  ZipDecoder zipDecoder = ZipDecoder();
  @override
  List<BaseCommand> processResponse({required DownloadTranslationResponse pResponse}) {
    Archive archive = zipDecoder.decodeBytes(pResponse.bodyBytes);

    return [
      SaveApplicationTranslationCommand(translations: archive.files, reason: "Downloaded Translations"),
    ];
  }
}
