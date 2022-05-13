import 'package:flutter/material.dart';

/// Class defining various colors.
abstract class IColorConstants {
  static const Color COMPONENT_DISABLED = Color(0xFFBDBDBD);

  static const Color ICONTROL_BACKGROUND = Color(0xFFFFFFFF);
  static const Color ICONTROL_ALTERNATEBACKGROUND = Color(0xFFFFFFFF);
  static const Color ICONTROL_FOREGROUND = Color(0xFFFFFFFF);
  static const Color ICONTROL_ACTIVESELECTIONBACKGROUND = Color(0xFFFFFFFF);
  static const Color ICONTROL_ACTIVESELECTIONFOREGROUND = Color(0xFFFFFFFF);
  static const Color ICONTROL_INACTIVESELECTIONBACKGROUND = Color(0xFFFFFFFF);
  static const Color ICONTROL_INACTIVESELECTIONFOREGROUND = Color(0xFFFFFFFF);
  static const Color ICONTROL_MANDATORYBACKGROUND = Color(0xFFFFFFFF);
  static const Color ICONTROL_READONLYBACKGROUND = Color(0xFFFFFFFF);
  static const Color ICONTROL_INVALIDEDITORBACKGROUND = Color(0xFFFFFFFF);

  static const Map<String, Color> SERVER_COLORS = {
    "icontrol_background": ICONTROL_BACKGROUND,
    "icontrol_alternateBackground": ICONTROL_ALTERNATEBACKGROUND,
    "icontrol_foreground": ICONTROL_FOREGROUND,
    "icontrol_activeSelectionBackground": ICONTROL_ACTIVESELECTIONBACKGROUND,
    "icontrol_activeSelectionForeground": ICONTROL_ACTIVESELECTIONFOREGROUND,
    "icontrol_inactiveSelectionBackground": ICONTROL_INACTIVESELECTIONBACKGROUND,
    "icontrol_inactiveSelectionForeground": ICONTROL_INACTIVESELECTIONFOREGROUND,
    "icontrol_mandatoryBackground": ICONTROL_MANDATORYBACKGROUND,
    "icontrol_readOnlyBackground": ICONTROL_READONLYBACKGROUND,
    "icontrol_invalidEditorBackground": ICONTROL_INVALIDEDITORBACKGROUND
  };
}

abstract class IColor extends IColorConstants {
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
