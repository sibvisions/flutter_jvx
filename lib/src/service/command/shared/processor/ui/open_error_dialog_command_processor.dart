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
    // Will be displayed in Splash if context is null
    if (FlutterUI.getCurrentContext() != null) {
      bool goToSettings = command.isTimeout || command.canBeFixedInSettings;
      // Don't show "Go to Settings" while in settings
      if (FlutterUI.getBeamerDelegate().currentBeamLocation.runtimeType == SettingsLocation) {
        goToSettings = false;
      }

      IUiService().showJVxDialog(
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
