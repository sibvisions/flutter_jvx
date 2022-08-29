import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../../../../mixin/ui_service_mixin.dart';
import '../../../../../mask/error/server_dialog.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/open_message_dialog_command.dart';
import '../../i_command_processor.dart';

class OpenMessageDialogCommandProcessor extends ICommandProcessor<OpenMessageDialogCommand> with UiServiceGetterMixin {
  @override
  Future<List<BaseCommand>> processCommand(OpenMessageDialogCommand command) async {
    Widget dialog = ServerDialog(
      message: command.message,
      messageScreenName: command.messageScreenName,
    );

    unawaited(getUiService().openDialog(
      pBuilder: (_) => dialog,
      pIsDismissible: false,
    ));

    return [];
  }
}
