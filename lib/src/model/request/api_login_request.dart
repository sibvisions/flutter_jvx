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

import '../../service/api/shared/api_object_property.dart';
import '../command/api/login_command.dart';
import 'session_request.dart';

/// Request to login into the app
class ApiLoginRequest extends SessionRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// See [LoginMode] class
  final LoginMode? loginMode;

  /// Username
  final String? username;

  /// Password
  final String? password;

  /// Either one-time-password or new password
  final String? newPassword;

  /// "Remember me"
  final bool? createAuthKey;

  /// Confirmation Code
  final String? confirmationCode;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiLoginRequest({
    this.loginMode,
    this.username,
    this.password,
    this.newPassword,
    this.createAuthKey,
    this.confirmationCode,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() =>
      {
        ...super.toJson(),
        ApiObjectProperty.loginMode: loginMode?.name,
        ApiObjectProperty.username: username,
        ApiObjectProperty.password: password,
        ApiObjectProperty.newPassword: newPassword,
        ApiObjectProperty.createAuthKey: createAuthKey,
        ApiObjectProperty.confirmationCode: confirmationCode,
      };
}
