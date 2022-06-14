import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_client/src/model/api/response/downloadTranslationResponse.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/api/shared/i_processor.dart';

class DownloadTranslationProcessor implements IProcessor<DownloadTranslationResponse> {
  ZipDecoder zipDecoder = ZipDecoder();
  @override
  List<BaseCommand> processResponse({required DownloadTranslationResponse pResponse}) {
    Archive archive = zipDecoder.decodeBytes(pResponse.bodyBytes);

    for (ArchiveFile file in archive) {
      String fileContent = utf8.decode(file.content);

      // log(fileContent);
    }

    return [];
  }
}
