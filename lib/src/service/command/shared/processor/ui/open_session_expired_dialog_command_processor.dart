import 'package:flutter/material.dart';
import 'package:flutter_client/src/mask/error/server_session_expired.dart';
import 'package:flutter_client/src/mixin/ui_service_getter_mixin.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/ui/open_session_expired_dialog_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class OpenSessionExpiredDialogCommandProcessor extends ICommandProcessor<OpenSessionExpiredDialogCommand>
  with UiServiceGetterMixin{

  @override
  Future<List<BaseCommand>> processCommand(OpenSessionExpiredDialogCommand command) async {

    Widget dialog = ServerSessionExpired(
        message: command.message
    );

    getUiService().openDialog(
        pDialogWidget: dialog,
        pIsDismissible: false
    );

    return [];
  }

}