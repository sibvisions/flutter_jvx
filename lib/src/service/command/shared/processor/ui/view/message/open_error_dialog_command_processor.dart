import 'dart:async';

import 'package:beamer/beamer.dart';

import '../../../../../../../../mixin/ui_service_mixin.dart';
import '../../../../../../../mask/error/server_error_dialog.dart';
import '../../../../../../../model/command/base_command.dart';
import '../../../../../../../model/command/ui/view/message/open_error_dialog_command.dart';
import '../../../../../../../routing/locations/settings_location.dart';
import '../../../../../../ui/i_ui_service.dart';
import '../../../../i_command_processor.dart';

class OpenErrorDialogCommandProcessor extends ICommandProcessor<OpenErrorDialogCommand> with UiServiceGetterMixin {
  @override
  Future<List<BaseCommand>> processCommand(OpenErrorDialogCommand command) async {
    bool goToSettings = command.isTimeout || command.canBeFixedInSettings;
    //Don't show "Go to Settings" while in settings
    if (IUiService.getCurrentContext().currentBeamLocation.runtimeType == SettingsLocation) {
      goToSettings = false;
    }

    unawaited(getUiService().openDialog(
      pBuilder: (_) => ServerErrorDialog(
        command: command,
        goToSettings: goToSettings,
      ),
      pIsDismissible: false,
    ));

    return [];
  }
}
