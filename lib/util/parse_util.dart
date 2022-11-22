import 'package:flutter/material.dart';

import '../commands.dart';
import '../flutter_jvx.dart';
import '../src/model/layout/layout_position.dart';
import '../src/model/response/application_settings_response.dart';

abstract class ParseUtil {
  static T? castOrNull<T>(dynamic x) => x is T ? x : null;

  static bool isHTML(String? text) {
    return text != null && text.length >= 6 && text.substring(0, 6).toLowerCase().startsWith("<html>");
  }

  /// Will return true if string == "true", false if string == "false"
  /// otherwise returns null.
  static bool? parseBool(dynamic pBool) {
    if (pBool != null) {
      if (pBool == "true") {
        return true;
      } else if (pBool == "false") {
        return false;
      }
    }
    return null;
  }

  /// Parses a [Size] object from a string, will only parse correctly if provided string was formatted :
  /// "x,y" - e.g. "200,400" -> Size(200,400), if provided String was null, returned size will also be null
  static Size? parseSize(dynamic pSize) {
    if (pSize != null && pSize is String) {
      List<String> split = pSize.split(",");

      double width = double.parse(split[0]);
      double height = double.parse(split[1]);

      return Size(width, height);
    }
    return null;
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
              isComponentSize: true);
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
    double textScaleFactor = pTextScaleFactor ?? MediaQuery.textScaleFactorOf(FlutterJVx.getCurrentContext()!);
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

  static dynamic getPropertyValue({
    required Map<String, dynamic> pJson,
    required String pKey,
    required dynamic pDefault,
    required dynamic pCurrent,
    dynamic Function(dynamic)? pConversion,
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

    if ((pCondition == null || pCondition.call(value)) && pConversion != null) {
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
          pDestination[sourceKey] = Map<String, dynamic>.from(value);
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
}
