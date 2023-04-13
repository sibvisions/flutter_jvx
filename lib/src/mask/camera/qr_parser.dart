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

import 'dart:convert';

import '../../config/qr_config.dart';
import '../../config/server_config.dart';
import '../../flutter_ui.dart';

class QRParser {
  /// Parses the given qr code.
  ///
  /// Default format:
  /// ```json
  /// {
  ///   "APPNAME": "demo",
  ///   "URL": "http://localhost:8888/JVx.mobile/services/mobile",
  ///   "USER": "features",
  ///   "PWD": "features",
  ///   "TITLE": "Demo App",
  ///   "ICON": "https://www.google.com/s2/favicons?domain=sibvisions.com&sz=256",
  ///   "DEFAULT": true
  /// }
  /// ```
  ///
  /// Supports the following legacy formats:
  /// * JSON
  /// * Custom "JSON" (=)
  /// ```
  /// {
  ///   URL=http://localhost:8080/JVx.mobile/services/mobile
  ///   APPNAME=demo
  ///   USER=features
  ///   PWD=features
  /// }
  /// ```
  /// * Simple Properties (: )
  /// ```
  /// Application: demo
  /// URL: http://localhost:8080/JVx.mobile/services/mobile
  /// USER: features
  /// PWD: features
  /// ```
  static QRConfig parse(String raw) {
    Map<String, dynamic> parsedConfig = {};
    // If QR-Code is a json it can be easily parsed, otherwise string is split by newLines.
    try {
      parsedConfig = jsonDecode(raw);
    } on FormatException {
      FlutterUI.logUI.d("Failed to parse valid json from qr code, falling back to line format.");

      LineSplitter ls = const LineSplitter();
      List<String> properties = ls.convert(raw);

      for (String prop in properties) {
        List<String> splitProp = prop.split(RegExp(r"(: )|(=)"));
        if (splitProp.length >= 2) {
          parsedConfig[splitProp[0]] = splitProp[1];
        }
      }
    }

    if (parsedConfig.isNotEmpty) {
      List<ServerConfig> collectedApps = [];
      ServerConfig rootConfig = ServerConfig.fromQR(parsedConfig);
      if (rootConfig.isValid) {
        collectedApps.add(rootConfig);
      }
      if (parsedConfig.containsKey(QRConfig.APPS)) {
        List<dynamic> apps = parsedConfig[QRConfig.APPS];
        collectedApps.addAll(apps.map((e) => ServerConfig.fromQR(e)).where((element) => element.isValid));
      }
      String? privacyPolicy = parsedConfig[QRConfig.POLICY];

      return QRConfig(
        policy: privacyPolicy != null ? Uri.parse(privacyPolicy.trim()) : null,
        apps: collectedApps,
      );
    }
    throw const FormatException("Invalid QR Code");
  }
}
