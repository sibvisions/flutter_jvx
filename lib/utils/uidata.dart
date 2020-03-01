import 'dart:ui';

import 'package:flutter/material.dart';

class UIData {
  //fonts
  static const String quickFont = "Quicksand";
  static const String ralewayFont = "Raleway";
  static const String quickBoldFont = "Quicksand_Bold.otf";
  static const String quickNormalFont = "Quicksand_Book.otf";
  static const String quickLightFont = "Quicksand_Light.otf";

  static const int sibblue = 0xFF055ba2;

  static const MaterialColor ui_kit_color = Colors.grey;
  static MaterialColor ui_kit_color_2 = Colors.blue;

  static const SIB_BLUE = MaterialColor(
    sibblue,
    <int, Color>{
      50: Color(sibblue),
      100: Color(0xFF1a77c2),
      200: Color(sibblue),
      300: Color(sibblue),
      400: Color(sibblue),
      500: Color(0xFF1868a8),
      600: Color(sibblue),
      700: Color(sibblue),
      800: Color(sibblue),
      900: Color(sibblue),
    }
  );

  static const JVX_BLUE = MaterialColor(
    sibblue,
    <int, Color>{
      50: Color.fromRGBO(0,55,88, .1),
      100: Color.fromRGBO(0,55,88, .2),
      200: Color.fromRGBO(0,55,88, .3),
      300: Color.fromRGBO(0,55,88, .4),
      400: Color.fromRGBO(0,55,88, .5),
      500: Color.fromRGBO(0,55,88, .6),
      600: Color.fromRGBO(0,55,88, .7),
      700: Color.fromRGBO(0,55,88, .8),
      800: Color.fromRGBO(0,55,88, .9),
      900: Color.fromRGBO(0,55,88, 1),
    }
  );

//colors
  static List<Color> kitGradients = [
    Colors.blueGrey.shade800,
    Colors.black87,
  ];
  static List<Color> kitGradients2 = [
    UIData.ui_kit_color_2,
    UIData.ui_kit_color_2[400]
  ];

  static Color textColor = UIData.ui_kit_color_2.computeLuminance() > 0.5
      ? Colors.black
      : Colors.white;
}
