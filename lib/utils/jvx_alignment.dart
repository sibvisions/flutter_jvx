import 'package:flutter/widgets.dart';

class JVxAlignment {
  static Alignment defaultAlignment = Alignment.topLeft;

  static Alignment getAlignmentFromInt(int textAlign) {
    switch(textAlign) {
      case 0: return Alignment.topLeft;
      case 1: return Alignment.center;
      case 2: return Alignment.topRight;
      case 3: return Alignment.center;
    }
    return defaultAlignment;
  }
}