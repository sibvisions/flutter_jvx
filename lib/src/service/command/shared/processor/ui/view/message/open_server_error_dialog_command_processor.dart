import 'dart:async';

import 'package:beamer/beamer.dart';

import '../../../../../../../../flutter_jvx.dart';
import '../../../../../../../../services.dart';
import '../../../../../../../mask/error/server_error_dialog.dart';
import '../../../../../../../model/command/base_command.dart';
import '../../../../../../../model/command/ui/view/message/open_server_error_dialog_command.dart';
import '../../../../../../../routing/locations/settings_location.dart';
import '../../../../i_command_processor.dart';

class OpenServerErrorDialogCommandProcessor extends ICommandProcessor<OpenServerErrorDialogCommand> {
  @override
  Future<List<BaseCommand>> processCommand(OpenServerErrorDialogCommand command) async {
    //Will be displayed in Splash if context is null
    if (FlutterJVx.getCurrentContext() != null) {
      bool goToSettings = command.userError;
      //Don't show "Go to Settings" while in settings
      if (FlutterJVx.getCurrentContext()?.currentBeamLocation.runtimeType == SettingsLocation) {
        goToSettings = false;
      }

      IUiService().showFrameDialog(
        ServerErrorDialog(
          command: command,
          goToSettings: goToSettings,
        ),
      );
    }
    return [];
  }
}
