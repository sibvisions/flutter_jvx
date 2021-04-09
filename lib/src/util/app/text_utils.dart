import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class TextUtils {
  static String averageCharactersTextField = "EARIOTNSLCaeiou";
  static String averageCharactersDateField = "31. November 2020 15:";

  static double getTextWidth(dynamic text, TextStyle style,
      [double textScaleFactor = 1.0,
      TextAlign align = TextAlign.left,
      TextDirection textDirection = TextDirection.ltr]) {
    return TextUtils.getTextSize(
            text, style, textScaleFactor, align, textDirection)
        .width;
  }

  static double getTextHeight(dynamic text, TextStyle style,
      [double textScaleFactor = 1.0,
      TextAlign align = TextAlign.left,
      TextDirection textDirection = TextDirection.ltr]) {
    return TextUtils.getTextSize(
            text, style, textScaleFactor, align, textDirection)
        .height;
  }

  static Size getTextSize(dynamic text, TextStyle style, double textScaleFactor,
      [TextAlign align = TextAlign.left,
      TextDirection textDirection = TextDirection.ltr]) {
    TextSpan span = new TextSpan(style: style, text: text);
    TextPainter tp = new TextPainter(
        text: span,
        textAlign: align,
        textDirection: textDirection,
        textScaleFactor: textScaleFactor
        // textScaleFactor: kIsWeb ? 1.15 : 1.1
        );
    tp.layout();

    return tp.size;
  }

  static String getCharactersWithLength(int length) {
    String text = averageCharactersTextField;
    double count = length / text.length;

    if (count > 1) {
      int countInt = count.floor();
      for (int i = 1; i < countInt; i++) text += averageCharactersTextField;
    }

    return text.substring(0, length);
  }

  static bool unfocusCurrentTextfield(BuildContext context) {
    bool hasListeners = false;
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    FocusScope.of(context).requestFocus(new FocusNode());
    return hasListeners;
  }
}
