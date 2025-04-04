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

import '../../../../../model/command/api/open_screen_command.dart';
import '../../../../../model/command/api/reload_menu_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_reload_menu_request.dart';
import '../../../../api/i_api_service.dart';
import '../../../../ui/i_ui_service.dart';
import '../../../i_command_service.dart';
import '../../i_command_processor.dart';

class ReloadMenuCommandProcessor extends ICommandProcessor<ReloadMenuCommand> {
  @override
  Future<List<BaseCommand>> processCommand(ReloadMenuCommand command, BaseCommand? origin) async {
    return IApiService().sendRequest(ApiReloadMenuRequest());
  }

  @override
  Future<void> onFinish(ReloadMenuCommand command) async {
    if (command.screenLongName != null) {
      if (IUiService().getMenuModel().containsScreen(command.screenLongName!)) {
        unawaited(ICommandService().sendCommand(OpenScreenCommand(
          longName: command.screenLongName!,
          reason: command.reason,
        )));
      }
    } else if (command.screenClassName != null) {
      if (IUiService().getMenuModel().getMenuItemByClassName(command.screenClassName!) != null) {
        unawaited(ICommandService().sendCommand(OpenScreenCommand(
          className: command.screenClassName!,
          reason: command.reason,
        )));
      }
    }
  }
}
