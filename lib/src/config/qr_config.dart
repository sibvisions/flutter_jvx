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

import 'dart:convert';

import 'server_config.dart';

class QRConfig {
  static const String APPS = "APPS";
  static const String POLICY = "POLICY";

  static const String APP_NAME = "APPNAME";
  static const String URL = "URL";
  static const String USER = "USER";
  static const String PASSWORD = "PWD";
  static const String TITLE = "TITLE";
  static const String ICON = "ICON";
  static const String IS_DEFAULT = "DEFAULT";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Legacy fields
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static const String APPLICATION = "Application";
  static const String APPLIKATION = "Applikation";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final Uri? policy;
  final List<ServerConfig>? apps;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const QRConfig({
    this.policy,
    this.apps,
  });

  const QRConfig.empty() : this();

  QRConfig.fromQR(Map<String, dynamic> json)
      : this(
          policy: json[POLICY] != null ? Uri.parse(json[POLICY].trim()) : null,
          apps: (json[APPS] as List<dynamic>?)?.map((e) => ServerConfig.fromQR(e)).where((e) => e.isValid).toList(),
        );

  static String generateQrCode(ServerConfig serverConfig) {
    return jsonEncode(serverConfig.toQR());
  }

  QRConfig merge(QRConfig? other) {
    if (other == null) return this;

    return QRConfig(
      policy: other.policy ?? policy,
      apps: other.apps ?? apps,
    );
  }

  Map<String, dynamic> toQR() => {
        POLICY: policy,
        APPS: apps?.map((e) => e.toJson()).toList(),
      };
}
