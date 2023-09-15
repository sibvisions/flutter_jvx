/*
 * Copyright 2023 SIB Visions GmbH
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

import '../../../../../../flutter_ui.dart';
import '../../../../../../mask/login/login_page.dart';
import '../../../../../../model/command/api/logout_command.dart';
import '../../../../../../model/command/base_command.dart';
import '../../../../../../model/command/ui/route/route_to_login_command.dart';
import '../../../../../apps/i_app_service.dart';
import '../../../../../config/i_config_service.dart';
import '../../../../../service.dart';
import '../../../../../ui/impl/ui_service.dart';
import '../../../i_command_processor.dart';

class RouteToLoginCommandProcessor extends ICommandProcessor<RouteToLoginCommand> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(RouteToLoginCommand command, BaseCommand? origin) async {
    // As a [LoginViewResponse] can also indicate a logout initiated by the server, clear user data here.
    await IConfigService().updateUserInfo(pUserInfo: null, pJson: null);
    await IConfigService().updateAuthKey(null);
    await IConfigService().updatePassword(null);

    await FlutterUI.clearServices(ClearReason.LOGOUT);

    if (origin is! LogoutCommand) {
      IAppService().saveLocationAsReturnUri();
    }

    if (UiService.checkForExistingRoute(false)) {
      FlutterUI.clearHistory();
      LoginPage.changeMode(mode: command.mode, loginData: command.loginData);
      FlutterUI.clearLocationHistory();
    }

    return [];
  }
}
