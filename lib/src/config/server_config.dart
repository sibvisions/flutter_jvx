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

import '../util/parse_util.dart';

class ServerConfig {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String? baseUrl;
  final String? appName;
  final String? username;
  final String? password;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const ServerConfig({
    this.baseUrl,
    this.appName,
    this.username,
    this.password,
  });

  const ServerConfig.empty() : this();

  ServerConfig.fromJson(Map<String, dynamic> json)
      : this(
          baseUrl: ParseUtil.isNotEmptyOrNull(json['baseUrl']),
          appName: ParseUtil.isNotEmptyOrNull(json['appName']),
          username: ParseUtil.isNotEmptyOrNull(json['username']),
          password: ParseUtil.isNotEmptyOrNull(json['password']),
        );

  ServerConfig merge(ServerConfig? other) {
    if (other == null) return this;

    return ServerConfig(
      baseUrl: other.baseUrl ?? baseUrl,
      appName: other.appName ?? appName,
      username: other.username ?? username,
      password: other.password ?? password,
    );
  }

  Map<String, dynamic> toJson() => {
        'baseUrl': baseUrl,
        'appName': appName,
        'username': username,
        'password': password,
      };
}
