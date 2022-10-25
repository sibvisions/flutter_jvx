import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

abstract class JVxColors {
  static const Color LIGHTER_BLACK = Color(0xFF424242);
  static const Color COMPONENT_DISABLED = Color(0xFFBDBDBD);

  static Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  static Color averageBetween(Color pSource, Color pTarget) {
    final source = HSLColor.fromColor(pSource);
    final target = HSLColor.fromColor(pTarget);

    final a = (source.alpha + target.alpha) / 2;
    final h = (source.hue + target.hue) / 2;
    final s = (source.saturation + target.saturation) / 2;
    final l = (source.lightness + target.lightness) / 2;

    return HSLColor.fromAHSL(a, h, s, l).toColor();
  }

  static Color toggleColor(Color pSource) {
    if (pSource.computeLuminance() > 0.5) {
      return darken(pSource);
    }
    return lighten(pSource);
  }
}
