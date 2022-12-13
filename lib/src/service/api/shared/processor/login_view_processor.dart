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

import '../../../../model/command/base_command.dart';
import '../../../../model/command/ui/route_to_login_command.dart';
import '../../../../model/request/api_login_request.dart';
import '../../../../model/request/api_request.dart';
import '../../../../model/response/login_view_response.dart';
import '../api_object_property.dart';
import '../i_response_processor.dart';

class LoginViewProcessor implements IResponseProcessor<LoginViewResponse> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BaseCommand> processResponse(LoginViewResponse pResponse, ApiRequest? pRequest) {
    Map<String, String?> loginProps = {
      ApiObjectProperty.username: pResponse.username,
    };

    if (pRequest is ApiLoginRequest) {
      loginProps[ApiObjectProperty.password] = pRequest.password;
    }

    RouteToLoginCommand routeToLoginCommand = RouteToLoginCommand(
      mode: pResponse.mode,
      reason: "Login as response",
      loginData: loginProps,
    );

    return [routeToLoginCommand];
  }
}
