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

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../config/server_config.dart';
import '../flutter_ui.dart';
import '../model/layout/layout_position.dart';
import '../model/response/application_settings_response.dart';
import '../service/api/shared/api_object_property.dart';

abstract class ParseUtil {
  static const String urlSuffix = "/services/mobile";

  static bool isHTML(String? text) {
    return text != null && text.length >= 6 && text.substring(0, 6).toLowerCase().startsWith("<html>");
  }

  static Uri appendJVxUrlSuffix(Uri uri) {
    if (!uri.path.endsWith(urlSuffix) && !uri.path.endsWith("$urlSuffix/")) {
      String appendingSuffix = urlSuffix;
      if (uri.path.endsWith("/")) {
        appendingSuffix = appendingSuffix.substring(1);
      }
      uri = uri.replace(path: uri.path + appendingSuffix);
    }
    return uri;
  }

  static Duration? validateDuration(Duration? duration) =>
      duration == null || duration == Duration.zero || duration.isNegative ? null : duration;

  /// Will return the boolean, parse a string (true if string == "true", false if string == "false")
  /// otherwise returns null.
  static bool? parseBool(dynamic pBool) {
    if (pBool != null) {
      if (pBool is bool) {
        return pBool;
      } else if (pBool.toString().toLowerCase() == "true") {
        return true;
      } else if (pBool.toString().toLowerCase() == "false") {
        return false;
      }
    }
    return null;
  }

  /// Will return the boolean, parse a string (true if string == "true", false if string == "false")
  /// otherwise returns false.
  static bool parseBoolOrFalse(dynamic pBool) {
    return parseBool(pBool) ?? false;
  }

  /// Will return the boolean, parse a string (true if string == "true", false if string == "false")
  /// otherwise returns true.
  static bool parseBoolOrTrue(dynamic pBool) {
    return parseBool(pBool) ?? true;
  }

  static Color? parseBackgroundColor(dynamic pValue) {
    String? jsonBackground = pValue?.toString();
    List<String> listBackgroundValues = jsonBackground?.split(";") ?? [];

    List<String> exludedBackgroundColors = [ApiObjectProperty.mandatoryBackground];

    if (listBackgroundValues.length >= 2 && exludedBackgroundColors.contains(listBackgroundValues[1])) {
      return null;
    }
    return parseServerColor(pValue);
  }

  static Color? parseServerColor(dynamic pValue) {
    return ColorConverter.fromJson(pValue?.toString());
  }

  /// Parses 6 or 8 digit hex-integers to colors.
  /// <br><br>
  /// Server sends the following values:
  /// <ul>
  ///   <li>0x or 0X in AARRGGBB or RRGGBB.</li>
  ///   <li>#RRGGBBAA or #RRGGBB.</li>
  /// <ul>
  static Color? parseHexColor(String? pValue) {
    if (pValue == null) {
      return null;
    } else if (pValue.startsWith("#")) {
      if (pValue.characters.length == 9) {
        return Color.fromARGB(
          int.parse(pValue.substring(7, 9), radix: 16),
          int.parse(pValue.substring(3, 5), radix: 16),
          int.parse(pValue.substring(5, 7), radix: 16),
          int.parse(pValue.substring(1, 3), radix: 16),
        );
      } else if (pValue.characters.length == 7) {
        return Color.fromARGB(
          0xFF,
          int.parse(pValue.substring(1, 3), radix: 16),
          int.parse(pValue.substring(3, 5), radix: 16),
          int.parse(pValue.substring(5, 7), radix: 16),
        );
      }
    } else if (pValue.startsWith("0x") || pValue.startsWith("0X")) {
      if (pValue.characters.length == 10) {
        return Color.fromARGB(
          int.parse(pValue.substring(2, 4), radix: 16),
          int.parse(pValue.substring(4, 6), radix: 16),
          int.parse(pValue.substring(6, 8), radix: 16),
          int.parse(pValue.substring(8, 10), radix: 16),
        );
      } else if (pValue.characters.length == 8) {
        return Color.fromARGB(
          0xFF,
          int.parse(pValue.substring(2, 4), radix: 16),
          int.parse(pValue.substring(4, 6), radix: 16),
          int.parse(pValue.substring(6, 8), radix: 16),
        );
      }
    }
    return null;
  }

  static EdgeInsets? parseMargins(String? pValue) {
    if (pValue != null) {
      var splitString = pValue.split(",");
      if (splitString.isNotEmpty && splitString.length == 4) {
        int top = int.tryParse(splitString[0]) ?? 0;
        int left = int.tryParse(splitString[1]) ?? 0;
        int bottom = int.tryParse(splitString[2]) ?? 0;
        int right = int.tryParse(splitString[3]) ?? 0;

        return EdgeInsets.fromLTRB(left.toDouble(), top.toDouble(), right.toDouble(), bottom.toDouble());
      }
    }
    return null;
  }

  static LayoutPosition? parseBounds(dynamic pValue) {
    if (pValue != null && pValue is String) {
      var splitString = pValue.split(",");
      if (splitString.isNotEmpty && splitString.length == 4) {
        int? left = int.tryParse(splitString[0]);
        int? top = int.tryParse(splitString[1]);
        int? width = int.tryParse(splitString[2]);
        int? height = int.tryParse(splitString[3]);

        if (left != null && top != null && width != null && height != null) {
          return LayoutPosition(
            width: width.toDouble(),
            height: height.toDouble(),
            top: top.toDouble(),
            left: left.toDouble(),
          );
        }
      }
    }
    return null;
  }

  static TextPainter getTextPainter({
    required String text,
    required TextStyle style,
    double? pTextScaleFactor,
    TextAlign align = TextAlign.left,
    TextDirection textDirection = TextDirection.ltr,
    double maxWidth = double.infinity,
    int maxLines = 1,
  }) {
    double textScaleFactor = pTextScaleFactor ?? MediaQuery.textScaleFactorOf(FlutterUI.getCurrentContext()!);
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      maxLines: maxLines,
      textAlign: align,
      textScaleFactor: textScaleFactor,
    )..layout(minWidth: 0, maxWidth: maxWidth);

    return textPainter;
  }

  static Size getTextSize({
    required String text,
    required TextStyle style,
    double? pTextScaleFactor,
    TextAlign align = TextAlign.left,
    TextDirection textDirection = TextDirection.ltr,
    double maxWidth = double.infinity,
    int maxLines = 1,
  }) {
    return getTextPainter(
            text: text,
            style: style,
            pTextScaleFactor: pTextScaleFactor,
            align: align,
            textDirection: textDirection,
            maxWidth: maxWidth,
            maxLines: maxLines)
        .size;
  }

  static double getTextHeight({
    required String text,
    required TextStyle style,
    double? pTextScaleFactor,
    TextAlign align = TextAlign.left,
    TextDirection textDirection = TextDirection.ltr,
    double maxWidth = double.infinity,
    int maxLines = 1,
  }) {
    return getTextPainter(
            text: text,
            style: style,
            pTextScaleFactor: pTextScaleFactor,
            align: align,
            textDirection: textDirection,
            maxWidth: maxWidth,
            maxLines: maxLines)
        .height;
  }

  static double getTextWidth({
    required String text,
    required TextStyle style,
    double? pTextScaleFactor,
    TextAlign align = TextAlign.left,
    TextDirection textDirection = TextDirection.ltr,
    double maxWidth = double.infinity,
    int maxLines = 1,
  }) {
    return getTextPainter(
            text: text,
            style: style,
            pTextScaleFactor: pTextScaleFactor,
            align: align,
            textDirection: textDirection,
            maxWidth: maxWidth,
            maxLines: maxLines)
        .width;
  }

  static T getPropertyValue<T>({
    required Map<String, dynamic> pJson,
    required String pKey,
    required T pDefault,
    required T pCurrent,
    T Function(dynamic)? pConversion,
    bool Function(dynamic)? pCondition,
  }) {
    if (!pJson.containsKey(pKey)) {
      return pCurrent;
    }

    dynamic value = pJson[pKey];

    // Explicitly null values reset the value back to the default.
    if (value == null) {
      return pDefault;
    }

    if (pCondition != null && pCondition.call(value) == false) {
      return pDefault;
    }

    if (pConversion != null) {
      return pConversion.call(value);
    } else {
      return value;
    }
  }

  static applyJsonToJson(Map<String, dynamic> pSource, Map<String, dynamic> pDestination) {
    for (String sourceKey in pSource.keys) {
      dynamic value = pSource[sourceKey];

      if (value is Map<String, dynamic>) {
        if (pDestination[sourceKey] == null) {
          pDestination[sourceKey] = Map.of(value);
        } else {
          applyJsonToJson(value, pDestination[sourceKey]);
        }
      } else {
        pDestination[sourceKey] = value;
      }
    }
  }

  static String? propertyAsString(String? property) {
    if (property == null) return null;
    String result = property.split(".").last.toLowerCase().replaceAll("\$", "~");

    if (result.contains("___")) {
      result = result.replaceAll("___", "?");

      result = result.replaceAll("__", ".");

      result = _enumToCamelCase(result);

      result = result.replaceAll("?", "_");
    } else if (result.contains("__")) {
      result.split("__").asMap().forEach((i, p) {
        if (i == 0) {
          result = p;
        } else {
          result += ".${p.toLowerCase()}";
        }
      });

      result = _enumToCamelCase(result);
    } else if (result.contains("_")) {
      result = _enumToCamelCase(result);
    }

    return result;
  }

  static String _enumToCamelCase(String string) {
    string.split("_").asMap().forEach((i, p) {
      if (i == 0) {
        string = p;
      } else if (p.isNotEmpty) {
        string += "${p[0].toUpperCase()}${p.substring(1)}";
      }
    });
    return string;
  }

  static String? ensureNullOnEmpty(String? value) {
    return value == "" ? null : value;
  }

  /// Extracts a [ServerConfig] from [data].
  ///
  /// Returns either a valid [ServerConfig] or `null`.
  static ServerConfig? extractAppParameters(Map<String, dynamic> data) {
    String? appName = data.remove("appName") as String?;
    Uri? baseUrl = Uri.tryParse(data.remove("baseUrl") ?? "::"); //Empty string returns uri, "::" not.
    String? username = (data.remove("username") ?? data.remove("userName")) as String?;
    String? password = data.remove("password") as String?;
    String? title = data.remove("title") as String?;

    ServerConfig extractedConfig = ServerConfig(
      appName: appName,
      baseUrl: baseUrl,
      title: title,
      username: username,
      password: password,
    );

    if (extractedConfig.isValid) {
      return extractedConfig;
    }

    return null;
  }

  static List<BarcodeFormat>? parseScanFormat(String s) {
    List<BarcodeFormat> formats = [];
    switch (s) {
      case "All":
        return [BarcodeFormat.all];
      case "CodeAll":
        formats.addAll([
          BarcodeFormat.code128,
          BarcodeFormat.code39,
          BarcodeFormat.code93,
          BarcodeFormat.codebar,
        ]);
      case "Code128":
        formats.add(BarcodeFormat.code128);
      case "Code39":
        formats.add(BarcodeFormat.code39);
      case "Code93":
        formats.add(BarcodeFormat.code93);
      case "Codebar":
        formats.add(BarcodeFormat.codebar);
      case "DataMatrix":
        formats.add(BarcodeFormat.dataMatrix);
      case "EanAll":
        formats.addAll([
          BarcodeFormat.ean13,
          BarcodeFormat.ean8,
        ]);
      case "Ean13":
        formats.add(BarcodeFormat.ean13);
      case "Ean8":
        formats.add(BarcodeFormat.ean8);
      case "Itf":
        formats.add(BarcodeFormat.itf);
      case "QrCode":
        formats.add(BarcodeFormat.qrCode);
      case "UpcAll":
        return [
          BarcodeFormat.upcA,
          BarcodeFormat.upcE,
        ];
      case "UpcA":
        formats.add(BarcodeFormat.upcA);
      case "UpcE":
        formats.add(BarcodeFormat.upcE);
      case "pdf417":
        formats.add(BarcodeFormat.pdf417);
      case "Aztec":
        formats.add(BarcodeFormat.aztec);
      default:
        return null;
    }
    return formats;
  }
}
