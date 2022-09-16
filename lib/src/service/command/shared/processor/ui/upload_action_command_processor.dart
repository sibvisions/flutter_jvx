import 'dart:async';

import '../../../../../../mixin/services.dart';
import '../../../../../model/command/api/upload_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/upload_action_command.dart';
import '../../../../../util/file_picker_dialog.dart';
import '../../i_command_processor.dart';

class UploadActionCommandProcessor with UiServiceMixin implements ICommandProcessor<UploadActionCommand> {
  @override
  Future<List<BaseCommand>> processCommand(UploadActionCommand command) async {
    unawaited(openFilePicker().then((value) {
      if (value != null) {
        getUiService().sendCommand(UploadCommand(fileId: command.fileId, file: value, reason: "Uploading file"));
      }
    }));

    return [];
  }
}
