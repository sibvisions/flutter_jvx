import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_client/src/mask/error/server_error_dialog.dart';
import 'package:flutter_client/src/mixin/ui_service_getter_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/ui/open_error_dialog_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

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
