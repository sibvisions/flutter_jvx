import 'dart:ui';

class HexColor extends Color {
  static RegExp colorHex = RegExp(r"^#[A-Fa-f0-9-]{6}$");

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  static bool isHexColor(dynamic hexColor) {
    if (hexColor is String) {
      return colorHex.hasMatch(hexColor.toUpperCase());
    }
    return false;
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
