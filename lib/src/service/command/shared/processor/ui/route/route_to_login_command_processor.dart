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

import 'package:beamer/beamer.dart';

import '../../../../../../flutter_ui.dart';
import '../../../../../../model/command/base_command.dart';
import '../../../../../../model/command/ui/route/route_to_login_command.dart';
import '../../../../../apps/app_service.dart';
import '../../../../../config/i_config_service.dart';
import '../../../../../ui/i_ui_service.dart';
import '../../../i_command_processor.dart';

class RouteToLoginCommandProcessor extends ICommandProcessor<RouteToLoginCommand> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(RouteToLoginCommand command) async {
    // As a [LoginViewResponse] can also indicate a logout initiated by the server, clear user data here.
    await IConfigService().updateUserInfo(pUserInfo: null, pJson: null);
    await IConfigService().updateAuthKey(null);
    await IConfigService().updatePassword(null);

    await FlutterUI.clearServices(false);

    // Save the current location (if inside a screen) to return to it after login.
    BeamState? targetState = FlutterUI.getCurrentContext()?.currentBeamLocation.state as BeamState?;
    if (targetState != null && targetState.uri.path.startsWith("/screens/")) {
      AppService().savedReturnUri ??= Uri(path: targetState.uri.path);
    }

    IUiService().routeToLogin(mode: command.mode, pLoginProps: command.loginData);

    return [];
  }
}
