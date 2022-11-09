import 'dart:async';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_download_command.dart';
import '../../i_command_processor.dart';

class SaveDownloadCommandProcessor implements ICommandProcessor<SaveDownloadCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveDownloadCommand command) async {
    if (kIsWeb) {
      // https://github.com/incrediblezayed/file_saver/issues/42
      // File saver ignores the extension property so we have to include it in the name itself
      unawaited(
        FileSaver.instance.saveFile(
          path.basename(command.fileName),
          command.bodyBytes,
          "",
        ),
      );
    } else {
      String extension = path.extension(command.fileName);
      if (extension.startsWith(".")) {
        extension = extension.substring(1);
      }
      unawaited(
        FileSaver.instance.saveAs(
          path.basenameWithoutExtension(command.fileName),
          command.bodyBytes,
          "extension",
          MimeType.OTHER,
        ),
      );
    }

    return [];
  }
}
