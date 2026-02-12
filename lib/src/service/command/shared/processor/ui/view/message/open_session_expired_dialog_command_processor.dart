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

import '../../../../../../../mask/error/server_session_expired_dialog.dart';
import '../../../../../../../model/command/api/startup_command.dart';
import '../../../../../../../model/command/base_command.dart';
import '../../../../../../../model/command/ui/view/message/open_session_expired_dialog_command.dart';
import '../../../../../../apps/i_app_service.dart';
import '../../../../../../config/i_config_service.dart';
import '../../../../../../ui/i_ui_service.dart';
import '../../../../i_command_processor.dart';

class OpenSessionExpiredDialogCommandProcessor extends ICommandProcessor<OpenSessionExpiredDialogCommand> {
  @override
  Future<List<BaseCommand>> processCommand(OpenSessionExpiredDialogCommand command, BaseCommand? origin) async {
    IUiService servUi = IUiService();

    servUi.updateClientId(null);

    if (!IConfigService().getAppConfig()!.autoRestartOnSessionExpired!
        //restart while starting won't work because of an endless loop
        || origin is StartupCommand) {
      servUi.showJVxDialog(ServerSessionExpiredDialog(command: command));
    } else {
      IAppService servApp = IAppService();

      //MARK: Save last screen for reopen after restart
      servApp.saveLocationAsReturnUri();

      //use appTitle of last application. This is important if JVxSplash has a hardcoded appName
      unawaited(servApp.startApp(appTitle: servApp.getCurrentApp()?.effectiveTitle));
    }

    return [];
  }
}
