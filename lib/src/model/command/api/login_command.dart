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

import 'api_command.dart';

/// All available login request modes
enum LoginMode {
  /// manual login.
  Manual,

  /// change password.
  ChangePassword,

  /// change one-time password.
  ChangeOneTimePassword,

  /// lost password.
  LostPassword,

  /// automatic login.
  Automatic,

  /// multi-factor text input.
  MFTextInput,

  /// multi-factor wait.
  MFWait,

  /// multi-factor URL.
  MFURL,
}

class LoginCommand extends ApiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// See [LoginMode] class
  final LoginMode loginMode;

  /// Username
  final String userName;

  /// Password
  final String password;

  /// Either one-time-password or new password
  final String? newPassword;

  /// "Remember me"
  final bool createAuthKey;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  LoginCommand({
    required this.loginMode,
    required this.userName,
    required this.password,
    this.createAuthKey = false,
    this.newPassword,
    required super.reason,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "LoginCommand{userName: $userName, loginMode: $loginMode, createAuthKey: $createAuthKey, ${super.toString()}}";
  }
}
