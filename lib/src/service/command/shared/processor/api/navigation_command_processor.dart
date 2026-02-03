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

import '../../../../../model/command/api/close_screen_command.dart';
import '../../../../../model/command/api/navigation_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/storage/save_components_command.dart';
import '../../../../../model/request/api_navigation_request.dart';
import '../../../../api/i_api_service.dart';
import '../../../../api/shared/api_object_property.dart';
import '../../i_command_processor.dart';

/// Will send [ApiNavigationRequest] to remote server
class NavigationCommandProcessor extends ICommandProcessor<NavigationCommand> {
  @override
  Future<List<BaseCommand>> processCommand(NavigationCommand command, BaseCommand? origin) async {
    List<BaseCommand> commands = await IApiService().sendRequest(
      ApiNavigationRequest(
        componentId: command.componentName,
      ),
    );

    // if commands is empty, close screen
    bool closeScreen = commands.isEmpty;

    //As a rule: If response contains real UI changes (not only remove and destroy) -> don't close because the UI
    //is changing
    if (!closeScreen) {
      //no SaveComponentsCommand -> close screen
      bool hasOnlyRemoveAndDestroy = true;

      for (int i = 0; i < commands.length; i++) {
        if (commands[i] is SaveComponentsCommand) {
          SaveComponentsCommand cmd = commands[i] as SaveComponentsCommand;

          if (cmd.changedComponents != null) {
            //if ALL changes contain ~remove or ~destroy -> no UI changes -> close Screen
            hasOnlyRemoveAndDestroy = cmd.changedComponents!.every((change) {
              return change.containsKey(ApiObjectProperty.remove) ||
                change.containsKey(ApiObjectProperty.destroy);
            });
          }
        }
      }

      closeScreen = hasOnlyRemoveAndDestroy;
    }

    if (closeScreen) {
      commands.add(CloseScreenCommand(componentName: command.componentName, reason: "Navigation response was empty"));
    }

    return commands;
  }
}
