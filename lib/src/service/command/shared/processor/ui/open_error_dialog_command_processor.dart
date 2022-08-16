import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

import '../../../../../../mixin/ui_service_mixin.dart';
import '../../../../../mask/error/server_error_dialog.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/open_error_dialog_command.dart';
import '../../../../../routing/locations/settings_location.dart';
import '../../i_command_processor.dart';

class OpenErrorDialogCommandProcessor extends ICommandProcessor<OpenErrorDialogCommand> with UiServiceGetterMixin {
  @override
  Future<List<BaseCommand>> processCommand(OpenErrorDialogCommand command) async {
    bool goToSettings = command.isTimeout || command.canBeFixedInSettings;
    //Don't show "Go to Settings" while in settings
    if (getUiService().getBuildContext()!.currentBeamLocation.runtimeType == SettingsLocation) {
      goToSettings = false;
    }

    Widget errorWidget = ServerErrorDialog(
      message: command.message,
      goToSettings: goToSettings,
    );

    await getUiService().openDialog(
      pDialogWidget: errorWidget,
      pIsDismissible: false,
    );

    return [];
  }
}
