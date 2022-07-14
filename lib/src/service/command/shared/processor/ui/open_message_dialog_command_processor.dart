import 'package:flutter/material.dart';

import '../../../../../mask/error/server_dialog.dart';
import '../../../../../mixin/ui_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/open_message_dialog_command.dart';
import '../../i_command_processor.dart';

class OpenMessageDialogCommandProcessor extends ICommandProcessor<OpenMessageDialogCommand> with UiServiceGetterMixin {
  @override
  Future<List<BaseCommand>> processCommand(OpenMessageDialogCommand command) async {
    Widget messageWidget = ServerDialog(
      message: command.message,
      messageScreenName: command.messageScreenName,
    );

    await getUiService().openDialog(pDialogWidget: messageWidget, pIsDismissible: false);

    return [];
  }
}
