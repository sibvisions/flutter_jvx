import 'package:archive/archive.dart';
import 'package:flutter_client/src/model/api/response/download_images_response.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/config/save_application_images_command.dart';
import 'package:flutter_client/src/service/api/shared/i_processor.dart';

class DownloadImagesProcessor extends IProcessor<DownloadImagesResponse> {
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
