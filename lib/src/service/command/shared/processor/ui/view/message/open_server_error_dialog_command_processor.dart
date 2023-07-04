/* 
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:collection/collection.dart';

import '../../../../../../../flutter_ui.dart';
import '../../../../../../../mask/error/server_error_dialog.dart';
import '../../../../../../../model/command/base_command.dart';
import '../../../../../../../model/command/ui/view/message/open_server_error_dialog_command.dart';
import '../../../../../../ui/i_ui_service.dart';
import '../../../../i_command_processor.dart';

class OpenServerErrorDialogCommandProcessor extends ICommandProcessor<OpenServerErrorDialogCommand> {
  @override
  Future<List<BaseCommand>> processCommand(OpenServerErrorDialogCommand command, BaseCommand? origin) async {
    // Will be displayed in Splash if context is null
    if (FlutterUI.getCurrentContext() != null && !command.silentAbort) {
      bool goToSettings = command.userError;
      // Don't show "Go to Settings" while in settings
      if ((FlutterUI.getBeamerDelegate().currentBeamLocation.state as BeamState)
          .pathPatternSegments
          .contains("settings")) {
        goToSettings = false;
      }

      // Check if there isn't already another dialog with the same id
      if (command.componentId == null ||
          IUiService()
              .getJVxDialogs()
              .whereType<ServerErrorDialog>()
              .none((dialog) => dialog.command.componentId == command.componentId)) {
        IUiService().showJVxDialog(
          ServerErrorDialog(
            command: command,
            goToSettings: goToSettings,
          ),
        );
      }
    }
    return [];
  }
}
