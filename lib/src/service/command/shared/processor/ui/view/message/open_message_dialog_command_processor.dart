import 'dart:async';

import '../../../../../../../../mixin/services.dart';
import '../../../../../../../mask/error/message_dialog.dart';
import '../../../../../../../model/command/base_command.dart';
import '../../../../../../../model/command/ui/view/message/open_message_dialog_command.dart';
import '../../../../i_command_processor.dart';

class OpenMessageDialogCommandProcessor extends ICommandProcessor<OpenMessageDialogCommand> with UiServiceMixin {
  @override
  Future<List<BaseCommand>> processCommand(OpenMessageDialogCommand command) async {
    unawaited(getUiService().openDialog(
      pBuilder: (_) => MessageDialog(command: command),
      pIsDismissible: command.closable,
    ));

    return [];
  }
}
