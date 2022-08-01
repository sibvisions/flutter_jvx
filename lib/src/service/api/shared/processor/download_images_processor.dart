import 'package:archive/archive.dart';

import '../../../../model/response/download_images_response.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/config/save_application_images_command.dart';
import '../i_response_processor.dart';

class DownloadImagesProcessor extends IResponseProcessor<DownloadImagesResponse> {
  ZipDecoder zipDecoder = ZipDecoder();

  @override
  List<BaseCommand> processResponse({required DownloadImagesResponse pResponse}) {
    Archive archive = zipDecoder.decodeBytes(pResponse.responseBody);

    return [
      SaveApplicationImagesCommand(
        images: archive.files,
        reason: "Downloaded image zip",
      )
    ];
  }
}
