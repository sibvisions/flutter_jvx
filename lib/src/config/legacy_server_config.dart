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

import 'server_config.dart';

/// Scanned QR Code Data from an VisionX/Vaadin App-QR Code
class LegacyServerConfig {
  static const String APPNAME = "APPNAME";
  static const String URL = "URL";
  static const String USER = "USER";
  static const String PASSWORD = "PWD";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the app
  final String appName;

  /// Url of the remote server
  final String url;

  /// Username for auto-login
  final String? username;

  /// Password for auto-login
  final String? password;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  LegacyServerConfig({
    required this.appName,
    required this.url,
    this.username,
    this.password,
  });

  LegacyServerConfig.fromJson(Map<String, dynamic> json)
      : this(
          appName: json[APPNAME]!,
          url: json[URL]!,
          username: json[USER],
          password: json[PASSWORD],
        );

  ServerConfig asServerConfig() {
    return ServerConfig(
      appName: appName,
      baseUrl: Uri.parse(url),
      username: username,
      password: password,
    );
  }
}
