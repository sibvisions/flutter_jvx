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

import 'package:collection/collection.dart';

import '../../../../../model/command/api/close_screen_command.dart';
import '../../../../../model/command/api/navigation_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/storage/save_components_command.dart';
import '../../../../../model/request/api_navigation_request.dart';
import '../../../../api/i_api_service.dart';
import '../../../../api/shared/api_object_property.dart';
import '../../i_command_processor.dart';

/// Will send [ApiNavigationRequest] to remote server
class NavigationCommandProcessor implements ICommandProcessor<NavigationCommand> {
  @override
  Future<List<BaseCommand>> processCommand(NavigationCommand command) async {
    List<BaseCommand> commands = await IApiService().sendRequest(
      ApiNavigationRequest(
        screenName: command.openScreen,
      ),
    );

    // if commands is empty, close screen
    bool closeScreen = commands.isEmpty;

    // if commands is not empty, check if there are only changes with ~remove and ~destroy
    if (!closeScreen && commands.length == 1 && commands.first is SaveComponentsCommand) {
      SaveComponentsCommand saveComponentsCommand = commands.first as SaveComponentsCommand;
      if (saveComponentsCommand.isUpdate && saveComponentsCommand.newComponents == null) {
        if (saveComponentsCommand.changedComponents == null) {
          closeScreen = true;
        } else {
          closeScreen = saveComponentsCommand.changedComponents!.none((changedComponents) {
            return !changedComponents.containsKey(ApiObjectProperty.remove) &&
                !changedComponents.containsKey(ApiObjectProperty.destroy);
          });
        }
      }
    }

    if (closeScreen) {
      commands.add(CloseScreenCommand(screenName: command.openScreen, reason: "Navigation response was empty"));
    }

    return commands;
  }
}
