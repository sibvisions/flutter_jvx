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

import '../../../../../flutter_ui.dart';
import '../../../../../model/command/api/login_command.dart';
import '../../../../../model/command/api/startup_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_login_request.dart';
import '../../../../api/i_api_service.dart';
import '../../../../config/i_config_service.dart';
import '../../../../ui/i_ui_service.dart';
import '../../i_command_processor.dart';

class LoginCommandProcessor extends ICommandProcessor<LoginCommand> {
  @override
  Future<List<BaseCommand>> processCommand(LoginCommand command, BaseCommand? origin) async {
    String? clientId = IUiService().clientId.value;

    if (clientId != null) {
      // Save values from last login attempt (used for user convenience and MFA login)
      if (command.username?.isNotEmpty ?? false) {
        await IConfigService().updateUsername(command.username);
      }
      if (command.loginMode == LoginMode.Manual) {
        FlutterUI.of(FlutterUI.getCurrentContext()!).lastPassword = command.password;
      }

      ApiLoginRequest loginRequest = ApiLoginRequest(
        loginMode: command.loginMode,
        username: command.username,
        password: command.password,
        newPassword: command.newPassword,
        createAuthKey: command.createAuthKey,
        confirmationCode: command.confirmationCode,
      );
      return IApiService().sendRequest(loginRequest);
    } else {
      return [StartupCommand(reason: "Login failed")];
    }
  }
}
