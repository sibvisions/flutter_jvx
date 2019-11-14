import 'dart:ui';
import 'package:flutter/painting.dart';

class TextUtils {

  static int getTextWidth(dynamic text, TextStyle style, [TextAlign align = TextAlign.left, TextDirection textDirection = TextDirection.ltr]) {
    return TextUtils.getTextSize(text, style, align, textDirection).width.round();
  }

  static Size getTextSize(dynamic text, TextStyle style, [TextAlign align = TextAlign.left, TextDirection textDirection = TextDirection.ltr]) {
    TextSpan span = new TextSpan(style: style, text: text);
    TextPainter tp = new TextPainter(text: span, textAlign: align, textDirection: textDirection);
    tp.layout();

    return tp.size;
  }

}