import 'dart:async';

import 'package:file_saver/file_saver.dart';
import 'package:path/path.dart' as path;

import '../../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_download_command.dart';
import '../../i_command_processor.dart';

class SaveDownloadCommandProcessor with ConfigServiceGetterMixin implements ICommandProcessor<SaveDownloadCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveDownloadCommand command) async {
    unawaited(FileSaver.instance.saveAs(path.basenameWithoutExtension(command.fileName), command.bodyBytes,
        path.extension(command.fileName), MimeType.OTHER));

    return [];
  }
}
