import 'package:flutter/widgets.dart';

class JVxTextAlign {
  static TextAlign defaultAlign = TextAlign.left;

  static TextAlign getTextAlignFromInt(int textAlign) {
    switch(textAlign) {
      case 0: return TextAlign.left;
      case 1: return TextAlign.center;
      case 2: return TextAlign.right;
      case 3: return TextAlign.justify;
    }
    return defaultAlign;
  }
}