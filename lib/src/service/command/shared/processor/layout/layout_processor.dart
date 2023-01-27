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

import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/layout/layout_mode_command.dart';
import '../../../../../model/command/layout/preferred_size_command.dart';
import '../../../../../model/command/layout/register_parent_command.dart';
import '../../../../../model/response/device_status_response.dart';
import '../../../../layout/i_layout_service.dart';
import '../../../../ui/i_ui_service.dart';
import '../../i_command_processor.dart';

class LayoutProcessor implements ICommandProcessor {
  @override
  Future<List<BaseCommand>> processCommand(BaseCommand command) async {
    if (command is PreferredSizeCommand) {
      return ILayoutService().reportPreferredSize(pLayoutData: command.layoutData);
    } else if (command is RegisterParentCommand) {
      return ILayoutService().reportLayout(pLayoutData: command.layoutData);
    } else if (command is LayoutModeCommand) {
      IUiService().updateLayoutMode(command.layoutMode ?? LayoutMode.Small);
    }

    return [];
  }
}
