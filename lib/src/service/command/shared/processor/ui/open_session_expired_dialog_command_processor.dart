import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../../../../mixin/ui_service_mixin.dart';
import '../../../../../mask/error/server_session_expired.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/open_session_expired_dialog_command.dart';
import '../../i_command_processor.dart';

class OpenSessionExpiredDialogCommandProcessor extends ICommandProcessor<OpenSessionExpiredDialogCommand>
    with UiServiceGetterMixin {
  @override
  Future<List<BaseCommand>> processCommand(OpenSessionExpiredDialogCommand command) async {
    Widget dialog = ServerSessionExpired(message: command.message);

    unawaited(getUiService().openDialog(
      pBuilder: (_) => dialog,
      pIsDismissible: false,
    ));

    return [];
  }
}
