import 'dart:async';

import '../../../../../../../../flutter_jvx.dart';
import '../../../../../../../../services.dart';
import '../../../../../../../mask/error/server_session_expired.dart';
import '../../../../../../../model/command/base_command.dart';
import '../../../../../../../model/command/ui/view/message/open_session_expired_dialog_command.dart';
import '../../../../i_command_processor.dart';

class OpenSessionExpiredDialogCommandProcessor extends ICommandProcessor<OpenSessionExpiredDialogCommand> {
  @override
  Future<List<BaseCommand>> processCommand(OpenSessionExpiredDialogCommand command) async {
    if (!IConfigService().getAppConfig()!.autoRestartOnSessionExpired!) {
      IUiService().showFrameDialog(ServerSessionExpired(command: command));
    } else {
      FlutterJVxState.of(FlutterJVx.getCurrentContext())!.restart();
    }

    return [];
  }
}
