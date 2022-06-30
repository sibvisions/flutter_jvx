import 'package:flutter/material.dart';
import 'package:flutter_client/src/mask/error/server_dialog.dart';
import 'package:flutter_client/src/mixin/ui_service_getter_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/ui/open_message_dialog_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class OpenMessageDialogCommandProcessor extends ICommandProcessor<OpenMessageDialogCommand> with UiServiceGetterMixin {
  @override
  Future<List<BaseCommand>> processCommand(OpenMessageDialogCommand command) async {
    Widget messageWidget = ServerDialog(
      message: command.message,
      messageScreenName: command.messageScreenName,
    );

    getUiService().openDialog(pDialogWidget: messageWidget, pIsDismissible: false);

    return [];
  }
}
