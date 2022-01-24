import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/data/column_definition.dart';
import 'package:flutter_client/src/model/layout/layout_position.dart';

abstract class ParseUtil {
  /// Will return true if string == "true", false if string == "false"
  /// otherwise returns null.
  static bool? parseBoolFromString(String? pBoolString) {
    if (pBoolString != null) {
      if (pBoolString == "true") {
        return true;
      } else if (pBoolString == "false") {
        return false;
      }
    }
  }

  /// Parses a [Size] object from a string, will only parse correctly if provided string was formatted :
  /// "x,y" - e.g. "200,400" -> Size(200,400), if provided String was null, returned size will also be null
  static Size? parseSizeFromString(String? pSizeString) {
    if (pSizeString != null) {
      List<String> split = pSizeString.split(",");

      double width = double.parse(split[0]);
      double height = double.parse(split[1]);

      return Size(width, height);
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
      if (pValue.length == 9) {
        return Color.fromARGB(
            int.parse(pValue.substring(7, 9), radix: 16),
            int.parse(pValue.substring(3, 5), radix: 16),
            int.parse(pValue.substring(5, 7), radix: 16),
            int.parse(pValue.substring(1, 3), radix: 16));
      } else if (pValue.length == 7) {
        return Color.fromARGB(0xFF, int.parse(pValue.substring(1, 3), radix: 16),
            int.parse(pValue.substring(3, 5), radix: 16), int.parse(pValue.substring(5, 7), radix: 16));
      }
    } else if (pValue.startsWith("0x") || pValue.startsWith("0X")) {
      if (pValue.length == 10) {
        return Color.fromARGB(
            int.parse(pValue.substring(2, 4), radix: 16),
            int.parse(pValue.substring(4, 6), radix: 16),
            int.parse(pValue.substring(6, 8), radix: 16),
            int.parse(pValue.substring(8, 10), radix: 16));
      } else if (pValue.length == 8) {
        return Color.fromARGB(0xFF, int.parse(pValue.substring(2, 4), radix: 16),
            int.parse(pValue.substring(4, 6), radix: 16), int.parse(pValue.substring(6, 8), radix: 16));
      }
    }
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
  }

  static LayoutPosition? parseBounds(String? pValue) {
    if (pValue != null) {
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
}
