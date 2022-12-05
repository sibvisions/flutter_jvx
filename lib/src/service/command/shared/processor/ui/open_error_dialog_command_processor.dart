import 'dart:async';

import '../../../../../flutter_ui.dart';
import '../../../../../mask/error/error_dialog.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/open_error_dialog_command.dart';
import '../../../../../routing/locations/settings_location.dart';
import '../../../../ui/i_ui_service.dart';
import '../../i_command_processor.dart';

class OpenErrorDialogCommandProcessor extends ICommandProcessor<OpenErrorDialogCommand> {
  @override
  Future<List<BaseCommand>> processCommand(OpenErrorDialogCommand command) async {
    //Will be displayed in Splash if context is null
    if (FlutterUI.getCurrentContext() != null) {
      bool goToSettings = command.isTimeout || command.canBeFixedInSettings;
      //Don't show "Go to Settings" while in settings
      if (FlutterUI.getBeamerDelegate().currentBeamLocation.runtimeType == SettingsLocation) {
        goToSettings = false;
      }

      IUiService().showFrameDialog(
        ErrorDialog(
          title: command.title,
          message: command.message,
          goToSettings: goToSettings,
          dismissible: command.dismissible,
        ),
      );
    }
    return [];
  }
}
