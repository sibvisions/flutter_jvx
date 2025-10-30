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

import '../../../../../../../../flutter_jvx.dart';
import '../../../../../../../mask/error/server_session_expired_dialog.dart';
import '../../../../i_command_processor.dart';

class OpenSessionExpiredDialogCommandProcessor extends ICommandProcessor<OpenSessionExpiredDialogCommand> {
  @override
  Future<List<BaseCommand>> processCommand(OpenSessionExpiredDialogCommand command, BaseCommand? origin) async {
    IUiService().updateClientId(null);

    if (!IConfigService().getAppConfig()!.autoRestartOnSessionExpired!
        //restart while starting won't work because of an endless loop
        || origin is StartupCommand) {
      IUiService().showJVxDialog(ServerSessionExpiredDialog(command: command));
    } else {
      //use appTitle of last application. This is important if JVxSplash has a hardcoded appName
      unawaited(IAppService().startApp(appTitle: IAppService().getCurrentApp()?.effectiveTitle));
    }

    return [];
  }
}
