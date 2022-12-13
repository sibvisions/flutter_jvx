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

import 'dart:convert';

import '../../flutter_ui.dart';

class QRParser {
  static const String url = "URL";
  static const String appName = "APPNAME";
  static const String user = "USER";
  static const String password = "PWD";

  static const Map<String, String> propertyNameMap = {
    "URL": QRParser.url,
    "Applikation": QRParser.appName,
    "Application": QRParser.appName,
    "APPNAME": QRParser.appName,
    "USER": QRParser.user,
    "PWD": QRParser.password,
  };

  /// The following formats are supported:
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
  static QRAppCode parseCode(String rawQRCode) {
    Map<String, dynamic> json = {};

    // If QR-Code is a json it can be easily parsed, otherwise string is split by newLines.
    try {
      json = jsonDecode(rawQRCode);
    } on FormatException {
      FlutterUI.logUI.d("Failed to parse valid json from qr code, falling back to line format.");

      LineSplitter ls = const LineSplitter();
      List<String> properties = ls.convert(rawQRCode);

      for (String prop in properties) {
        List<String> splitProp = prop.split(RegExp(r"(: )|(=)"));
        String? propertyName = propertyNameMap[splitProp[0]];
        if (propertyName != null && splitProp.length >= 2) {
          String propertyValue = splitProp[1];
          json[propertyName] = propertyValue;
        }
      }
    }

    if (json.containsKey(QRParser.appName) && json.containsKey(QRParser.url)) {
      return QRAppCode.fromJson(json);
    }
    throw const FormatException("Invalid QR Code");
  }
}

/// Scanned QR Code Data from an VisionX App-QR Code
class QRAppCode {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Url of the remote server
  final String url;

  /// Name of the app
  final String appName;

  /// Username for auto-login
  final String? username;

  /// Password for auto-login
  final String? password;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  QRAppCode({
    required this.url,
    required this.appName,
    this.username,
    this.password,
  });

  QRAppCode.fromJson(Map<String, dynamic> json)
      : this(
          url: json[QRParser.url]!,
          appName: json[QRParser.appName]!,
          username: json[QRParser.user],
          password: json[QRParser.password],
        );
}
