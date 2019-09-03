import 'package:flutter/widgets.dart';

class JVxTextStyle {
  static TextStyle addFontToTextStyle(String fontString, [TextStyle style]) {
    FontStyle fontStyle = FontStyle.normal;
    FontWeight fontWeight = FontWeight.normal;
    double fontSize;

    List<String> fontParts = fontString?.split(",");

    if (fontParts!=null && fontParts.length==3) {
      int fontWeightStyle = int.parse(fontParts[1]);
      fontSize = double.parse(fontParts[2]);

      switch (fontWeightStyle) {
        case 0: fontWeight = FontWeight.normal;
                break;
        case 1: fontWeight = FontWeight.bold;
                break;
        case 2: fontStyle = FontStyle.italic;
                break;
      }

      if (style!=null) {
        return TextStyle(
          inherit: style.inherit,
          color: style.color,
          backgroundColor: style.backgroundColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: style.letterSpacing,
          wordSpacing: style.wordSpacing,
          textBaseline: style.textBaseline,
          height: style.height,
          locale: style.locale,
          foreground: style.foreground,
          background: style.background,
          shadows: style.shadows,
          fontFeatures: style.fontFeatures,
          decoration: style.decoration,
          decorationColor: style.decorationColor,
          decorationStyle: style.decorationStyle,
          decorationThickness: style.decorationThickness,
          debugLabel: style.debugLabel);
      } else {
        return TextStyle(fontFamily: fontParts[0], fontSize: fontSize, fontStyle: fontStyle, fontWeight: fontWeight);
      }
    }
    return style;
  }

static TextStyle addForecolorToTextStyle(Color color, [TextStyle style]) {
  if (style!=null) {
    return TextStyle(
      inherit: style.inherit,
      color: color,
      backgroundColor: style.backgroundColor,
      fontSize: style.fontSize,
      fontWeight: style.fontWeight,
      fontStyle: style.fontStyle,
      letterSpacing: style.letterSpacing,
      wordSpacing: style.wordSpacing,
      textBaseline: style.textBaseline,
      height: style.height,
      locale: style.locale,
      foreground: style.foreground,
      background: style.background,
      shadows: style.shadows,
      fontFeatures: style.fontFeatures,
      decoration: style.decoration,
      decorationColor: style.decorationColor,
      decorationStyle: style.decorationStyle,
      decorationThickness: style.decorationThickness,
      debugLabel: style.debugLabel);
    } else {
      return TextStyle(color: color);
    }
  }

}