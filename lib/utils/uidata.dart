import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class UIData {
  //fonts
  static const String quickFont = "Quicksand";
  static const String ralewayFont = "Raleway";
  static const String quickBoldFont = "Quicksand_Bold.otf";
  static const String quickNormalFont = "Quicksand_Book.otf";
  static const String quickLightFont = "Quicksand_Light.otf";

  static const MaterialColor ui_kit_color = Colors.grey;
  static const MaterialColor ui_kit_color_2 = Colors.blue;

//colors
  static List<Color> kitGradients = [
    Colors.blueGrey.shade800,
    Colors.black87,
  ];
  static List<Color> kitGradients2 = [Colors.blue, Colors.blue];

  static Color textColor = UIData.ui_kit_color_2.computeLuminance() > 0.5
      ? Colors.black
      : Colors.white;
}
