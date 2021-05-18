import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class TextUtils {
  static String averageCharactersNumberField = "1299,99";
  static String averageCharactersTextField = "EARIOTNSLCaeiou";
  static String averageCharactersDateField = "31. November 2020 15:";

  static Size getTextFieldSize(
      dynamic text, int columns, int rows, bool multiline, TextStyle style,
      [double textScaleFactor = 1.0,
      TextAlign align = TextAlign.left,
      TextDirection textDirection = TextDirection.ltr]) {
    double width = 0;
    double height = 0;
    String textToCalculate = text;

    if (columns > 0) {
      Size avgCharacter =
          getAverageCharacterSize(style, textScaleFactor, align, textDirection);
      width = avgCharacter.width * columns;

      if (rows > 0 && multiline) {
        height = avgCharacter.height * (rows + 1);
      } else if (multiline) {
        //height = height * 4;
      } else {
        height = avgCharacter.height;
      }
    } else {
      if (textToCalculate.isEmpty) textToCalculate = averageCharactersTextField;
      Size size = getTextSize(
          textToCalculate, style, textScaleFactor, align, textDirection);
      width = size.width;
      height = size.height;

      if (rows > 0 && multiline) {
        height = height * (rows + 1);
      } else if (multiline) {
        size = getTextSize(textToCalculate, style, textScaleFactor, align,
            textDirection, width);
        height = size.height;
      }
    }

    return Size(width, height);
  }

  static Size getAverageCharacterSize(TextStyle style,
      [double textScaleFactor = 1.0,
      TextAlign align = TextAlign.left,
      TextDirection textDirection = TextDirection.ltr]) {
    String testString = averageCharactersTextField;
    double widthSum = 0;
    double maxHeight = 0;
    testString.runes.forEach((rune) {
      var character = new String.fromCharCode(rune);
      Size size =
          getTextSize(character, style, textScaleFactor, align, textDirection);
      widthSum += size.width;
      maxHeight = max(maxHeight, size.height);
    });

    return Size(widthSum / testString.length, maxHeight);
  }

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
      TextDirection textDirection = TextDirection.ltr,
      double maxWidth = double.infinity]) {
    TextSpan span = new TextSpan(style: style, text: text);
    TextPainter tp = new TextPainter(
        text: span,
        textAlign: align,
        textDirection: textDirection,
        textScaleFactor: textScaleFactor);
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
