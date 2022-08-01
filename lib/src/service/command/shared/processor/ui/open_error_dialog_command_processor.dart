import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../../mixin/ui_service_mixin.dart';
import '../../../../../mask/error/server_error_dialog.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/open_error_dialog_command.dart';
import '../../i_command_processor.dart';

class OpenErrorDialogCommandProcessor extends ICommandProcessor<OpenErrorDialogCommand> with UiServiceGetterMixin {
  @override
  Future<List<BaseCommand>> processCommand(OpenErrorDialogCommand command) async {
    Widget errorWidget = ServerErrorDialog(
      message: command.message,
      isTimeout: command.isTimeout,
    );

    unawaited(getUiService().openDialog(
      pDialogWidget: errorWidget,
      pIsDismissible: false,
    ));

    return [];
  }
}
