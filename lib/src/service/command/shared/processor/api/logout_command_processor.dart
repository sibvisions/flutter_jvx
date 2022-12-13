/* Copyright 2022 SIB Visions GmbH
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

import '../../../../../model/command/api/logout_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_logout_request.dart';
import '../../../../api/i_api_service.dart';
import '../../../../config/i_config_service.dart';
import '../../i_command_processor.dart';

class LogoutCommandProcessor implements ICommandProcessor<LogoutCommand> {
  @override
  Future<List<BaseCommand>> processCommand(LogoutCommand command) async {
    if (await IConfigService().getFileManager().doesFileExist(pPath: "auth.txt")) {
      IConfigService().getFileManager().deleteFile(pPath: "/auth.txt");
    }

    await IConfigService().setUserInfo(pUserInfo: null, pJson: null);
    await IConfigService().setAuthCode(null);
    await IConfigService().setPassword(null);

    return IApiService().sendRequest(ApiLogoutRequest());
  }
}
