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

import '../../../../../../flutter_jvx.dart';
import '../../../../../model/command/api/focus_gained_command.dart';
import '../../../../../model/command/api/focus_lost_command.dart';
import '../../../../../model/command/ui/set_focus_command.dart';
import '../../../../../model/component/fl_component_model.dart';
import '../../i_command_processor.dart';

class SetFocusCommandProcessor implements ICommandProcessor<SetFocusCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SetFocusCommand command) async {
    if (command.focus) {
      return focus(command.componentId);
    } else {
      return unfocus(command.componentId);
    }
  }

  Future<List<BaseCommand>> focus(String pComponentId) async {
    if (IUiService().hasFocus(pComponentId)) {
      return [];
    }
    FlComponentModel? component = IStorageService().getComponentModel(pComponentId: pComponentId);
    if (component == null || !component.isFocusable) {
      return [];
    }

    IUiService().setFocus(pComponentId);

    List<BaseCommand> commands = [];

    FlComponentModel? previousFocus = IUiService().getFocus();
    if (previousFocus != null) {
      if (previousFocus.eventFocusLost) {
        commands
            .add(FocusLostCommand(componentName: previousFocus.name, reason: "Unfocused, next focus: $pComponentId"));
      }
    }

    if (component.eventFocusGained) {
      commands.add(FocusGainedCommand(componentName: component.name, reason: "Focused"));
    }

    return commands;
  }

  Future<List<BaseCommand>> unfocus(String pComponentId) async {
    if (!IUiService().hasFocus(pComponentId)) {
      return [];
    }
    IUiService().removeFocus(pComponentId);

    FlComponentModel? component = IStorageService().getComponentModel(pComponentId: pComponentId);
    if (component == null || !component.eventFocusLost) {
      return [];
    }

    return [FocusLostCommand(componentName: component.name, reason: "Unfocused")];
  }
}
