import 'dart:async';

import '../../../../../model/command/api/upload_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/upload_action_command.dart';
import '../../../../../util/file_picker_dialog.dart';
import '../../../../ui/i_ui_service.dart';
import '../../i_command_processor.dart';

class UploadActionCommandProcessor implements ICommandProcessor<UploadActionCommand> {
  @override
  Future<List<BaseCommand>> processCommand(UploadActionCommand command) async {
    unawaited(openFilePicker().then((value) {
      if (value != null) {
        IUiService().sendCommand(UploadCommand(fileId: command.fileId, file: value, reason: "Uploading file"));
      }
    }));

    return [];
  }
}
