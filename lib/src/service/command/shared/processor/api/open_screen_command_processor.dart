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

import 'package:flutter/foundation.dart';

import '../../../../../model/command/api/open_screen_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_open_screen_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';
import '../storage/delete_screen_command_processor.dart';

class OpenScreenCommandProcessor implements ICommandProcessor<OpenScreenCommand> {
  /// Send the open screen request to the server.
  ///
  /// [ApiOpenScreenRequest.manualClose] is only used while we are not in the web,
  /// as there is no way of knowing when to close a screen in the web.
  /// (User can navigate whenever and wherever they want)
  ///
  /// See also:
  /// * [DeleteScreenCommandProcessor.processCommand]
  @override
  Future<List<BaseCommand>> processCommand(OpenScreenCommand command) {
    return IApiService().sendRequest(
      ApiOpenScreenRequest(
        screenLongName: command.screenLongName,
        screenClassName: command.screenClassName,
        parameter: command.parameter,
        manualClose: !kIsWeb,
      ),
    );
  }
}
