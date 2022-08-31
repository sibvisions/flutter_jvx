import 'dart:async';

import '../../../../../../mixin/ui_service_mixin.dart';
import '../../../../../mask/error/server_dialog.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/view/message/open_message_dialog_command.dart';
import '../../i_command_processor.dart';

class OpenMessageDialogCommandProcessor extends ICommandProcessor<OpenMessageDialogCommand> with UiServiceGetterMixin {
  @override
  Future<List<BaseCommand>> processCommand(OpenMessageDialogCommand command) async {
    unawaited(getUiService().openDialog(
      pBuilder: (_) => ServerDialog(command: command),
      pIsDismissible: command.closable,
    ));

    return [];
  }
}
