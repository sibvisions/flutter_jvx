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
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/storage/delete_screen_command.dart';
import '../../../../../model/request/api_close_screen_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class CloseScreenCommandProcessor implements ICommandProcessor<CloseScreenCommand> {
  @override
  Future<List<BaseCommand>> processCommand(CloseScreenCommand command, BaseCommand? origin) async {
    List<BaseCommand> commands = await IApiService().sendRequest(
      ApiCloseScreenRequest(
        screenName: command.screenName,
        parameter: command.parameter,
      ),
    );

    commands = [
      DeleteScreenCommand(
        screenName: command.screenName,
        reason: "Navigation response was empty",
      ),
      ...commands
    ];

    return commands;
  }
}
