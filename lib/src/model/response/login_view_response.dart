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

import 'package:collection/collection.dart';

import '../../service/api/shared/api_object_property.dart';
import '../command/api/login_command.dart';
import 'api_response.dart';

/// Response to indicate to display the login screen
class LoginViewResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final LoginMode? mode;
  final String? username;
  final String? confirmationCode;
  final Link? link;
  final int? timeout;
  final bool? timeoutReset;
  final String? errorMessage;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  LoginViewResponse({
    this.mode,
    this.username,
    this.confirmationCode,
    this.link,
    this.timeout,
    this.timeoutReset,
    this.errorMessage,
    required super.name,
  });

  LoginViewResponse.fromJson(super.json)
      : mode = LoginMode.values
            .firstWhereOrNull((e) => e.name.toLowerCase() == json[ApiObjectProperty.mode].toLowerCase()),
        username = json[ApiObjectProperty.username],
        confirmationCode = json[ApiObjectProperty.confirmationCode],
        link = json[ApiObjectProperty.link] == null ? null : Link.fromJson(json[ApiObjectProperty.link]),
        timeout = json[ApiObjectProperty.timeout],
        timeoutReset = json[ApiObjectProperty.timeoutReset],
        errorMessage = json[ApiObjectProperty.errorMessage],
        super.fromJson();
}

class Link {
  final String? url;
  final String? target;
  final int? width;
  final int? height;

  Link({
    this.url,
    this.target,
    this.width,
    this.height,
  });

  Link.fromJson(Map<String, dynamic> json)
      : url = json[ApiObjectProperty.url],
        target = json[ApiObjectProperty.target],
        width = json[ApiObjectProperty.width],
        height = json[ApiObjectProperty.height];
}
