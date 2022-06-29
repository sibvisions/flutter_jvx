import 'package:flutter/material.dart';

import '../src/model/data/column_definition.dart';
import '../src/model/layout/layout_position.dart';
import 'constants/i_color.dart';

abstract class ParseUtil {
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

  static Color? parseServerColor(dynamic pValue) {
    if (pValue == null || pValue is! String) {
      return null;
    }

    var values = pValue.split(";");
    int serverStringIndex = values.length - 1;
    // TODO: change later so serverString index has priority
    // if (values[serverStringIndex].contains("#")) {
    if (values[0].contains("#")) {
      return parseHexColor(values[0]);
    } else {
      return IColorConstants.SERVER_COLORS[values[serverStringIndex]];
    }
  }

  /// Parses 6 or 8 digit hex-integers to colors.
  ///
  /// Starting with 0x or 0X in AARRGGBB or RRGGBB.
  ///
  /// Starting with # in RRGGBBAA o RRGGBB
  static Color? parseHexColor(String? pValue) {
    if (pValue == null) {
      return null;
    } else if (pValue.startsWith("#")) {
      if (pValue.characters.length == 9) {
        return Color.fromARGB(
            int.parse(pValue.substring(7, 9), radix: 16),
            int.parse(pValue.substring(3, 5), radix: 16),
            int.parse(pValue.substring(5, 7), radix: 16),
            int.parse(pValue.substring(1, 3), radix: 16));
      } else if (pValue.characters.length == 7) {
        return Color.fromARGB(0xFF, int.parse(pValue.substring(1, 3), radix: 16),
            int.parse(pValue.substring(3, 5), radix: 16), int.parse(pValue.substring(5, 7), radix: 16));
      }
    } else if (pValue.startsWith("0x") || pValue.startsWith("0X")) {
      if (pValue.characters.length == 10) {
        return Color.fromARGB(
            int.parse(pValue.substring(2, 4), radix: 16),
            int.parse(pValue.substring(4, 6), radix: 16),
            int.parse(pValue.substring(6, 8), radix: 16),
            int.parse(pValue.substring(8, 10), radix: 16));
      } else if (pValue.characters.length == 8) {
        return Color.fromARGB(0xFF, int.parse(pValue.substring(2, 4), radix: 16),
            int.parse(pValue.substring(4, 6), radix: 16), int.parse(pValue.substring(6, 8), radix: 16));
      }
    }
    return null;
  }

  static EdgeInsets? parseMargins(String? pValue) {
    if (pValue != null) {
      var splitString = pValue.split(",");
      if (splitString.isNotEmpty && splitString.length == 4) {
        int left = int.tryParse(splitString[0]) ?? 0;
        int top = int.tryParse(splitString[1]) ?? 0;
        int right = int.tryParse(splitString[2]) ?? 0;
        int bottom = int.tryParse(splitString[3]) ?? 0;

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

  /// Parse a json list of column definitions into a list of [ColumnDefinition] objects.
  static List<ColumnDefinition> parseColumnDefinitions(List<dynamic> pJsonColumnDefinitions) {
    List<ColumnDefinition> colDef = [];
    for (Map<String, dynamic> element in pJsonColumnDefinitions) {
      ColumnDefinition columnDefinition = ColumnDefinition();
      columnDefinition.applyFromJson(pJson: element);
      colDef.add(columnDefinition);
    }
    return colDef;
  }

  static TextPainter getTextPainter({
    required String text,
    required TextStyle style,
    double textScaleFactor = 1.0,
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
      textScaleFactor: textScaleFactor,
    )..layout(minWidth: 0, maxWidth: maxWidth);

    return textPainter;
  }

  static Size getTextSize({
    required String text,
    required TextStyle style,
    double textScaleFactor = 1.0,
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
    double textScaleFactor = 1.0,
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
    double textScaleFactor = 1.0,
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

  static dynamic getPropertyValue({
    required Map<String, dynamic> pJson,
    required String pKey,
    required dynamic pDefault,
    required dynamic pCurrent,
    dynamic Function(dynamic)? pConversion,
  }) {
    if (pJson.containsKey(pKey)) {
      dynamic value = pJson[pKey];
      if (value != null) {
        if (pConversion != null) {
          return pConversion.call(value);
        } else {
          return value;
        }
      } else {
        return pDefault;
      }
    }
    return pCurrent;
  }

  static applyJsonToJson(Map<String, dynamic> pSource, Map<String, dynamic> pDestination) {
    for (String sourceKey in pSource.keys) {
      dynamic value = pSource[sourceKey];

      if (value is Map<String, dynamic>) {
        if (pDestination[sourceKey] == null) {
          pDestination[sourceKey] = Map.from(value);
        } else {
          applyJsonToJson(value, pDestination[sourceKey]);
        }
      } else {
        pDestination[sourceKey] = value;
      }
    }
  }
}
