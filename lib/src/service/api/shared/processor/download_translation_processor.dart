import 'package:archive/archive.dart';

import '../../../../model/response/download_translation_response.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/config/save_application_translation_command.dart';
import '../i_response_processor.dart';

class DownloadTranslationProcessor implements IResponseProcessor<DownloadTranslationResponse> {
  ZipDecoder zipDecoder = ZipDecoder();
  @override
  List<BaseCommand> processResponse({required DownloadTranslationResponse pResponse}) {
    Archive archive = zipDecoder.decodeBytes(pResponse.bodyBytes);

    return [
      SaveApplicationTranslationCommand(translations: archive.files, reason: "Downloaded Translations"),
    ];
  }
}
