/*
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'package:flutter/material.dart';

abstract class JVxColors {
  static const Color LIGHTER_BLACK = Color(0xFF424242);
  static const Color DARKER_WHITE = Color(0xFFFAFAFA);

  static const Color TABLE_VERTICAL_DIVICER = Color(0xFFBDBDBD);
  static const Color TABLE_FOCUS_REACT = Color(0xFF666666);
  static const Color COMPONENT_BORDER = Color(0xFF999999);
  static const Color COMPONENT_DISABLED = Color(0xFFBDBDBD);
  static const Color COMPONENT_DISABLED_LIGHTER = Color(0xFFE6E6E6);
  static const Color TEXT_HINT_LABEL_COLOR = Color(0xFF999999);
  static const Color STANDARD_BORDER = Color(0xFF999999);

  /// Specifically requested color mix.
  static Color dividerColor(ThemeData theme) {
    return lighten(theme.colorScheme.onPrimary, 0.2);
  }

  /// Creates a JVx-conform theme.
  ///
  /// See also:
  /// * [applyJVxTheme]
  static ThemeData createTheme(
    Color seedColor,
    Brightness selectedBrightness, {
    bool useFixedPrimary = false,
  }) {
    ColorScheme colorScheme;
    if (useFixedPrimary) {
      bool isSeedLight = ThemeData.estimateBrightnessForColor(seedColor) == Brightness.light;

      colorScheme = ColorScheme.fromSeed(
        seedColor: seedColor,
        primary: selectedBrightness == Brightness.light ? seedColor : null,
        onPrimary: isSeedLight ? JVxColors.LIGHTER_BLACK : Colors.white,
        secondary: selectedBrightness == Brightness.light
            ? JVxColors.darken(seedColor, 0.1)
            : JVxColors.lighten(seedColor, 0.1),
        onSecondary: isSeedLight ? JVxColors.LIGHTER_BLACK : Colors.white,
        onTertiary: isSeedLight ? JVxColors.LIGHTER_BLACK : Colors.white,
        brightness: selectedBrightness,
        background: selectedBrightness == Brightness.light ? Colors.grey.shade50 : Colors.grey.shade900,
      );
    } else {
      colorScheme = ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: selectedBrightness,
        background: selectedBrightness == Brightness.light ? Colors.grey.shade50 : Colors.grey.shade900,
      );
    }

    var themeData = ThemeData.from(colorScheme: colorScheme, useMaterial3: false);
    themeData = applyJVxTheme(themeData);

    return themeData;
  }

  /// Whether this [color] is darker than the predefined [LIGHTER_BLACK] and therefore considered "black".
  static bool _isBlack(Color? color) {
    if (color == null) return false;
    return color.computeLuminance() <= JVxColors.LIGHTER_BLACK.computeLuminance();
  }

  /// Applies JVx specific color requirements to the [themeData].
  ///
  /// Basically this overrides every "known" theme color that is black with our [JVxColors.LIGHTER_BLACK].
  static ThemeData applyJVxTheme(ThemeData themeData) {
    if (_isBlack(themeData.canvasColor)) {
      themeData = themeData.copyWith(
        canvasColor: JVxColors.LIGHTER_BLACK,
      );
    }
    if (_isBlack(themeData.cardColor)) {
      themeData = themeData.copyWith(
        cardColor: JVxColors.LIGHTER_BLACK,
      );
    }
    if (_isBlack(themeData.textTheme.bodyLarge?.color)) {
      themeData = themeData.copyWith(
        textTheme: themeData.textTheme.apply(
          bodyColor: JVxColors.LIGHTER_BLACK,
          displayColor: JVxColors.LIGHTER_BLACK,
        ),
      );
    }
    if (_isBlack(themeData.primaryTextTheme.bodyLarge?.color)) {
      themeData = themeData.copyWith(
        primaryTextTheme: themeData.primaryTextTheme.apply(
          bodyColor: JVxColors.LIGHTER_BLACK,
          displayColor: JVxColors.LIGHTER_BLACK,
        ),
      );
    }
    if (_isBlack(themeData.iconTheme.color)) {
      themeData = themeData.copyWith(
        iconTheme: themeData.iconTheme.copyWith(
          color: JVxColors.LIGHTER_BLACK,
        ),
      );
    }
    if (_isBlack(themeData.primaryIconTheme.color)) {
      themeData = themeData.copyWith(
        iconTheme: themeData.primaryIconTheme.copyWith(
          color: JVxColors.LIGHTER_BLACK,
        ),
      );
    }

    return themeData;
  }

  /// Use [lighten] or [darken] depending on the [brightness].
  static Color adjustByBrightness(Brightness brightness, Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    if (brightness == Brightness.dark) {
      return lighten(color, amount);
    } else {
      return darken(color, amount);
    }
  }

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
