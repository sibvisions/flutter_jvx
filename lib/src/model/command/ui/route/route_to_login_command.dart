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

import '../../../../service/api/shared/api_object_property.dart';
import '../../../response/login_view_response.dart';
import '../../api/login_command.dart';
import 'route_command.dart';

/// Command to show the login page.
class RouteToLoginCommand extends RouteCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final LoginData loginData;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  RouteToLoginCommand({
    required this.loginData,
    required super.reason,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String propertiesAsString() {
    return "loginData: $loginData, ${super.propertiesAsString()}";
  }

}

class LoginData {
  final LoginMode mode;
  final String? username;
  final String? password;
  final String? newPassword;
  final String? confirmationCode;
  final Link? link;
  final int? timeout;
  final bool? timeoutReset;
  final String? errorMessage;

  LoginData({
    LoginMode? mode,
    this.username,
    this.password,
    this.newPassword,
    this.confirmationCode,
    this.link,
    this.timeout,
    this.timeoutReset,
    this.errorMessage,
  }) : mode = mode ?? LoginMode.Manual;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overriden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "LoginData{mode: $mode, username: $username, password: $password, newPassword: $newPassword, "
        "confirmationCode: $confirmationCode, link: $link, timeout: $timeout, "
        "timeoutReset: $timeoutReset, errorMessage: $errorMessage}";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is LoginData &&
      other.mode == mode &&
      other.username == username &&
      other.password == password &&
      other.newPassword == newPassword &&
      other.confirmationCode == confirmationCode &&
      other.link == link &&
      other.timeout == timeout &&
      other.timeoutReset == timeoutReset &&
      other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return mode.hashCode ^
      username.hashCode ^
      password.hashCode ^
      newPassword.hashCode ^
      confirmationCode.hashCode ^
      link.hashCode ^
      timeout.hashCode ^
      timeoutReset.hashCode ^
      errorMessage.hashCode;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Converts all not-null propertie to a map
  Map<String, dynamic> toMap() {
    return {
      ApiObjectProperty.mode: mode,
      if (username != null) ApiObjectProperty.username: username,
      if (password != null) ApiObjectProperty.password: password,
      if (newPassword != null) ApiObjectProperty.newPassword: newPassword,
      if (confirmationCode != null) ApiObjectProperty.confirmationCode: confirmationCode,
      if (link != null) ApiObjectProperty.link: link,
      if (timeout != null) ApiObjectProperty.timeout: timeout,
      if (timeoutReset != null) ApiObjectProperty.timeoutReset: timeoutReset,
      if (errorMessage != null) ApiObjectProperty.errorMessage: errorMessage,
    };
  }
}
