import 'dart:async';

import '../../../../../../../mask/error/message_dialog.dart';
import '../../../../../../../model/command/base_command.dart';
import '../../../../../../../model/command/ui/view/message/open_message_dialog_command.dart';
import '../../../../../../ui/i_ui_service.dart';
import '../../../../i_command_processor.dart';

class OpenMessageDialogCommandProcessor extends ICommandProcessor<OpenMessageDialogCommand> {
  @override
  Future<List<BaseCommand>> processCommand(OpenMessageDialogCommand command) async {
    IUiService().showFrame(
      componentId: command.componentId,
      pDialog: MessageDialog(command: command),
    );

    return [];
  }
}
