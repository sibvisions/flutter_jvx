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

import '../../config/legacy_server_config.dart';
import '../../config/server_config.dart';
import '../../flutter_ui.dart';
import '../../util/parse_util.dart';

class QRParser {
  static bool _isLegacy(String raw) {
    try {
      Map<String, dynamic> json = jsonDecode(raw);
      if (!json.containsKey(ApplicationConfig.APPS)) {
        return true;
      }
    } on FormatException {
      return true;
    }
    return false;
  }

  /// Parses the given [raw] qr code using [parseLatest] and [parseLegacy].
  static ApplicationConfig parse(String raw) {
    if (_isLegacy(raw)) {
      FlutterUI.log.d("Parsing legacy qr code");
      return parseLegacy(raw);
    } else {
      FlutterUI.log.d("Parsing qr code");
      return parseLatest(raw);
    }
  }

  /// Parses the latest qr code format.
  ///
  /// Supported format:
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
  static ApplicationConfig parseLatest(String raw) {
    Map<String, dynamic> json = jsonDecode(raw);
    return ApplicationConfig.fromJson(json);
  }

  /// Parsed a legacy qr code.
  ///
  /// The following legacy formats are supported:
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
  static ApplicationConfig parseLegacy(String rawQRCode) {
    const Map<String, String> dictionary = {
      "Application": LegacyServerConfig.APPNAME,
      "Applikation": LegacyServerConfig.APPNAME,
      "APPNAME": LegacyServerConfig.APPNAME,
      "URL": LegacyServerConfig.URL,
      "USER": LegacyServerConfig.USER,
      "PWD": LegacyServerConfig.PASSWORD,
    };

    Map<String, dynamic> parsedConfig = {};
    // If QR-Code is a json it can be easily parsed, otherwise string is split by newLines.
    try {
      parsedConfig = jsonDecode(rawQRCode);
    } on FormatException {
      FlutterUI.logUI.d("Failed to parse valid json from qr code, falling back to line format.");

      LineSplitter ls = const LineSplitter();
      List<String> properties = ls.convert(rawQRCode);

      for (String prop in properties) {
        List<String> splitProp = prop.split(RegExp(r"(: )|(=)"));
        String? propertyName = dictionary[splitProp[0]];
        if (propertyName != null && splitProp.length >= 2) {
          String propertyValue = splitProp[1];
          parsedConfig[propertyName] = propertyValue;
        }
      }
    }

    if (parsedConfig.isNotEmpty) {
      return ApplicationConfig(apps: [
        LegacyServerConfig.fromJson(parsedConfig).asServerConfig(),
      ]);
    }
    throw const FormatException("Invalid QR Code");
  }
}

class ApplicationConfig {
  static const String APPS = "APPS";

  static const String APP_NAME = "APPNAME";
  static const String URL = "URL";
  static const String USER = "USER";
  static const String PASSWORD = "PWD";
  static const String TITLE = "TITLE";
  static const String ICON = "ICON";
  static const String IS_DEFAULT = "DEFAULT";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final List<ServerConfig>? apps;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const ApplicationConfig({
    this.apps,
  });

  const ApplicationConfig.empty() : this();

  ApplicationConfig.fromJson(Map<String, dynamic> json)
      : this(
          apps: (json[APPS] as List<dynamic>?)?.map((e) {
            return ServerConfig(
              appName: ParseUtil.ensureNullOnEmpty(e[APP_NAME]),
              baseUrl: e[URL] != null ? Uri.parse(e[URL]) : null,
              username: ParseUtil.ensureNullOnEmpty(e[USER]),
              password: ParseUtil.ensureNullOnEmpty(e[PASSWORD]),
              title: ParseUtil.ensureNullOnEmpty(e[TITLE]),
              icon: ParseUtil.ensureNullOnEmpty(e[ICON]),
              isDefault: e[IS_DEFAULT],
            );
          }).toList(),
        );

  ApplicationConfig merge(ApplicationConfig? other) {
    if (other == null) return this;

    return ApplicationConfig(
      apps: other.apps ?? apps,
    );
  }

  Map<String, dynamic> toJson() => {
        'apps': apps?.map((e) => e.toJson()).toList(),
      };
}
