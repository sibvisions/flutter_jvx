import 'package:flutter/material.dart';

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Parses 6 or 8 digit hex-integers to colors.
  ///
  /// Starting with 0x or 0X in AARRGGBB or RRGGBB.
  ///
  /// Starting with # in RRGGBBAA o RRGGBB
  static Color parseHexColor(String? pValue) {
    if (pValue == null) {
      return Colors.black;
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

    return Colors.black;
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';

  static bool isHexColor(dynamic hexColor) {
    if (hexColor is String) {
      return RegExp(r"^#[A-Fa-f0-9-]{8}$").hasMatch(hexColor.toUpperCase());
    }
    return false;
  }

  Color textColor() {
    if (computeLuminance() > 0.5) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }
}
