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
import '../service/api/shared/api_object_property.dart';

abstract class ParseUtil {
  static const String mobileServicePath = "/services/mobile";
  static const String servicePath = "/services/";

  static bool isHTML(String? text) {
    return text != null && text.length >= 6 && text.substring(0, 6).toLowerCase().startsWith("<html>");
  }

  static Uri appendMobileServicePath(Uri uri) {
    String schemeLower = uri.scheme.toLowerCase();

    if ((schemeLower == "http" || schemeLower == "https")
        && !uri.path.endsWith(mobileServicePath)
        && !uri.path.endsWith("$mobileServicePath/")
        //maybe another service is configured
        && !uri.path.contains(servicePath)) {

      String appendingSuffix = mobileServicePath;

      if (uri.path.endsWith("/")) {
        appendingSuffix = appendingSuffix.substring(1);
      }

      uri = uri.replace(path: uri.path + appendingSuffix);
    }

    return uri;
  }

  static Duration? validateDuration(Duration? duration) =>
      duration == null || duration == Duration.zero || duration.isNegative ? null : duration;

  /// Will return the int, parse a string otherwise returns null.
  static int? parseInt(dynamic value) {
    if (value != null) {
      if (value is int) {
        return value;
      } else {
        return int.tryParse(value.toString());
      }
    }
    return null;
  }

  /// Will return the double, parse a string otherwise returns null.
  static double? parseDouble(dynamic value) {
    if (value != null) {
      if (value is double) {
        return value;
      } else {
        return double.tryParse(value.toString());
      }
    }
    return null;
  }

  /// Will return the boolean, parse a string (true if string == "true", false if string == "false")
  /// otherwise returns null.
  static bool? parseBool(dynamic value) {
    if (value != null) {
      if (value is bool) {
        return value;
      } else {
        return bool.tryParse(value.toString(), caseSensitive: false);
      }
    }
    return null;
  }

  /// Will return the boolean, parse a string (true if string == "true", false if string == "false")
  /// otherwise returns false.
  static bool parseBoolOrFalse(dynamic value) {
    return parseBool(value) ?? false;
  }

  /// Will return the boolean, parse a string (true if string == "true", false if string == "false")
  /// otherwise returns true.
  static bool parseBoolOrTrue(dynamic value) {
    return parseBool(value) ?? true;
  }

  static Color? parseBackgroundColor(dynamic value) {
    String? jsonBackground = value?.toString();
    List<String> listBackgroundValues = jsonBackground?.split(";") ?? [];

    List<String> excludedBackgroundColors = [ApiObjectProperty.mandatoryBackground];

    if (listBackgroundValues.length >= 2 && excludedBackgroundColors.contains(listBackgroundValues[1])) {
      return null;
    }
    return parseColor(value);
  }

  static Color? parseColor(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Color) {
      return value;
    }
    else {
      String valueAsString = value.toString();

      if (valueAsString.contains(";")) {
        valueAsString = valueAsString.split(";").first;
      }

      return parseHexColor(valueAsString);
    }
  }

  /// Parses 6 or 8 digit hex-integers to colors.
  /// <br><br>
  /// Server sends the following values:
  /// <ul>
  ///   <li>0x or 0X in AARRGGBB or RRGGBB.</li>
  ///   <li>#RRGGBBAA or #RRGGBB.</li>
  /// <ul>
  static Color? parseHexColor(String? value) {
    if (value == null) {
      return null;
    } else if (value.startsWith("#")) {
      if (value.characters.length == 9) {
        return Color.fromARGB(
          int.parse(value.substring(7, 9), radix: 16),
          int.parse(value.substring(3, 5), radix: 16),
          int.parse(value.substring(5, 7), radix: 16),
          int.parse(value.substring(1, 3), radix: 16),
        );
      } else if (value.characters.length == 7) {
        return Color.fromARGB(
          0xFF,
          int.parse(value.substring(1, 3), radix: 16),
          int.parse(value.substring(3, 5), radix: 16),
          int.parse(value.substring(5, 7), radix: 16),
        );
      }
    } else if (value.startsWith("0x") || value.startsWith("0X")) {
      if (value.characters.length == 10) {
        return Color.fromARGB(
          int.parse(value.substring(2, 4), radix: 16),
          int.parse(value.substring(4, 6), radix: 16),
          int.parse(value.substring(6, 8), radix: 16),
          int.parse(value.substring(8, 10), radix: 16),
        );
      } else if (value.characters.length == 8) {
        return Color.fromARGB(
          0xFF,
          int.parse(value.substring(2, 4), radix: 16),
          int.parse(value.substring(4, 6), radix: 16),
          int.parse(value.substring(6, 8), radix: 16),
        );
      }
    }
    else if (value == "transparent") {
      return Colors.transparent;
    }

    return null;
  }

  static EdgeInsets? parseMargins(String? value) {
    if (value != null) {
      var splitString = value.split(",");
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

  static LayoutPosition? parseBounds(dynamic value) {
    if (value != null && value is String) {
      var splitString = value.split(",");
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
    double? textScaleFactor,
    TextAlign align = TextAlign.left,
    TextDirection textDirection = TextDirection.ltr,
    double maxWidth = double.infinity,
    int maxLines = 1,
  }) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      maxLines: maxLines,
      textAlign: align,
      textScaler: TextScaler.linear(textScaleFactor ?? MediaQuery.textScalerOf(FlutterUI.getCurrentContext()!).scale(1))
    )..layout(minWidth: 0, maxWidth: maxWidth);

    return textPainter;
  }

  static Size getTextSize({
    required String text,
    required TextStyle style,
    double? textScaleFactor,
    TextAlign align = TextAlign.left,
    TextDirection textDirection = TextDirection.ltr,
    double maxWidth = double.infinity,
    int maxLines = 1,
  }) {
    return getTextPainter(
            text: text,
            style: style,
            textScaleFactor: textScaleFactor,
            align: align,
            textDirection: textDirection,
            maxWidth: maxWidth,
            maxLines: maxLines)
        .size;
  }

  static double getTextHeight({
    required String text,
    required TextStyle style,
    double? textScaleFactor,
    TextAlign align = TextAlign.left,
    TextDirection textDirection = TextDirection.ltr,
    double maxWidth = double.infinity,
    int maxLines = 1,
  }) {
    return getTextPainter(
            text: text,
            style: style,
            textScaleFactor: textScaleFactor,
            align: align,
            textDirection: textDirection,
            maxWidth: maxWidth,
            maxLines: maxLines)
        .height;
  }

  static double getTextWidth({
    required String text,
    required TextStyle style,
    double? textScaleFactor,
    TextAlign align = TextAlign.left,
    TextDirection textDirection = TextDirection.ltr,
    double maxWidth = double.infinity,
    int maxLines = 1,
  }) {
    return getTextPainter(
            text: text,
            style: style,
            textScaleFactor: textScaleFactor,
            align: align,
            textDirection: textDirection,
            maxWidth: maxWidth,
            maxLines: maxLines)
        .width;
  }

  static T getPropertyValue<T>({
    required Map<String, dynamic> json,
    required String key,
    required T defaultValue,
    required T currentValue,
    T Function(dynamic)? valueConversion,
    bool Function(dynamic)? condition,
  }) {
    if (!json.containsKey(key)) {
      return currentValue;
    }

    dynamic value = json[key];

    // Explicitly null values reset the value back to the default.
    if (value == null) {
      return defaultValue;
    }

    if (condition != null && condition.call(value) == false) {
      return defaultValue;
    }

    if (valueConversion != null) {
      return valueConversion.call(value);
    } else {
      return value;
    }
  }

  static bool applyJsonToJson(Map<String, dynamic> source, Map<String, dynamic> target) {

    bool isChanged = false;

    for (String sourceKey in source.keys) {
      dynamic value = source[sourceKey];

      if (value is Map<String, dynamic>) {
        if (target[sourceKey] == null) {
          target[sourceKey] = Map.of(value);

          isChanged = true;
        } else {
          isChanged |= applyJsonToJson(value, target[sourceKey]);
        }
      } else {
        if (target[sourceKey] != value) {
          target[sourceKey] = value;

          isChanged = true;
        }
      }
    }

    return isChanged;
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

  static String _enumToCamelCase(String value) {
    value.split("_").asMap().forEach((i, p) {
      if (i == 0) {
        value = p;
      } else if (p.isNotEmpty) {
        value += "${p[0].toUpperCase()}${p.substring(1)}";
      }
    });
    return value;
  }

  static String? ensureNullOnEmpty(String? value) {
    return value == "" ? null : value;
  }

  /// Extracts a [ServerConfig] from [data].
  ///
  /// Returns either a valid [ServerConfig] or `null`.
  static ServerConfig? extractAppParameters(Map<String, dynamic> data) {
    String? appName = data.remove("appName") as String?;
    Uri? baseUrl = data["baseUrl"] != null ? Uri.tryParse(data.remove("baseUrl")) : null;
    String? username = (data.remove("username") ?? data.remove("userName")) as String?;
    String? password = data.remove("password") as String?;
    String? title = data.remove("title") as String?;

    if (baseUrl != null) {
      baseUrl = ParseUtil.appendMobileServicePath(baseUrl);
    }

    return ServerConfig(
      appName: appName,
      baseUrl: baseUrl,
      title: title,
      username: username,
      password: password,
    );
  }

  static List<BarcodeFormat>? parseScanFormat(String format) {
    List<BarcodeFormat> formats = [];

    switch (format) {
      case "All":
        return [BarcodeFormat.all];
      case "CodeAll":
        formats.addAll([
          BarcodeFormat.code128,
          BarcodeFormat.code39,
          BarcodeFormat.code93,
          BarcodeFormat.codabar,
        ]);
      case "Code128":
        formats.add(BarcodeFormat.code128);
      case "Code39":
        formats.add(BarcodeFormat.code39);
      case "Code93":
        formats.add(BarcodeFormat.code93);
      case "Codebar":
      case "Codabar":
        formats.add(BarcodeFormat.codabar);
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
      case "Itf14":
      case "Itf":
        formats.add(BarcodeFormat.itf14);
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
