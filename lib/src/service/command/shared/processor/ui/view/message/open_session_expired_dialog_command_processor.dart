import 'dart:async';

import '../../../../../../../flutter_ui.dart';
import '../../../../../../../mask/error/server_session_expired.dart';
import '../../../../../../../model/command/base_command.dart';
import '../../../../../../../model/command/ui/view/message/open_session_expired_dialog_command.dart';
import '../../../../../../config/i_config_service.dart';
import '../../../../../../ui/i_ui_service.dart';
import '../../../../i_command_processor.dart';

class OpenSessionExpiredDialogCommandProcessor extends ICommandProcessor<OpenSessionExpiredDialogCommand> {
  @override
  Future<List<BaseCommand>> processCommand(OpenSessionExpiredDialogCommand command) async {
    IConfigService().setClientId(null);

    if (!IConfigService().getAppConfig()!.autoRestartOnSessionExpired!) {
      IUiService().showFrameDialog(ServerSessionExpired(command: command));
    } else {
      FlutterUIState.of(FlutterUI.getCurrentContext())!.restart();
    }

    return [];
  }
}
