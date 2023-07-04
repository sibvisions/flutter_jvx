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

import '../../../../../../../mask/error/message_dialog.dart';
import '../../../../../../../model/command/base_command.dart';
import '../../../../../../../model/command/ui/view/message/open_message_dialog_command.dart';
import '../../../../../../ui/i_ui_service.dart';
import '../../../../i_command_processor.dart';

class OpenMessageDialogCommandProcessor extends ICommandProcessor<OpenMessageDialogCommand> {
  @override
  Future<List<BaseCommand>> processCommand(OpenMessageDialogCommand command, BaseCommand? origin) async {
    IUiService().showJVxDialog(
      MessageDialog(
        command: command,
      ),
    );

    return [];
  }
}
