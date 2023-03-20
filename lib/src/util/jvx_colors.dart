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

  static const Color TABLE_VERTICAL_DIVICER = Color(0xFFBDBDBD);
  static const Color TABLE_FOCUS_REACT = Color(0xFF666666);
  static const Color COMPONENT_BORDER = Color(0xFF999999);
  static const Color COMPONENT_DISABLED = Color(0xFFBDBDBD);
  static const Color COMPONENT_DISABLED_LIGHTER = Color(0xFFE6E6E6);
  static const Color TEXT_HINT_LABEL_COLOR = Color(0xFF999999);
  static const Color STANDARD_BORDER = Color(0xFFBDBDBD);

  /// Specifically requested color mix.
  static Color dividerColor(ThemeData theme) {
    return lighten(theme.colorScheme.onPrimary, 0.2);
  }

  /// Creates a JVx-conform theme.
  ///
  /// See also:
  /// * [applyJVxColorScheme]
  /// * [applyJVxTheme]
  static ThemeData createTheme(MaterialColor materialColor, Brightness selectedBrightness) {
    ColorScheme colorScheme = ColorScheme.fromSwatch(
      primarySwatch: materialColor,
      brightness: selectedBrightness,
    );

    colorScheme = applyJVxColorScheme(colorScheme);

    // ColorScheme.fromSwatch related fix:
    // Override tealAccent
    colorScheme = colorScheme.copyWith(
      secondary: colorScheme.primary,
      onSecondary: colorScheme.onPrimary,
      secondaryContainer: colorScheme.primaryContainer,
      onSecondaryContainer: colorScheme.onPrimaryContainer,
      tertiary: colorScheme.primary,
      onTertiary: colorScheme.onPrimary,
      tertiaryContainer: colorScheme.primaryContainer,
      onTertiaryContainer: colorScheme.onPrimaryContainer,
    );

    var themeData = ThemeData.from(colorScheme: colorScheme);
    themeData = applyJVxTheme(themeData);

    // More ColorScheme.fromSwatch related fixes
    bool isBackgroundLight = ThemeData.estimateBrightnessForColor(colorScheme.background) == Brightness.light;
    themeData = themeData.copyWith(
      listTileTheme: themeData.listTileTheme.copyWith(
        textColor: isBackgroundLight ? JVxColors.LIGHTER_BLACK : Colors.white,
        iconColor: isBackgroundLight ? JVxColors.LIGHTER_BLACK : Colors.white,
        // textColor: themeData.colorScheme.onBackground,
        // iconColor: themeData.colorScheme.onBackground,
      ),
    );
    return themeData;
  }

  /// Applies JVx specific color requirements to the [colorScheme].
  ///
  /// Basically this overrides every "known" theme color that is black with our [JVxColors.LIGHTER_BLACK].
  ///
  /// See also:
  /// * [applyJVxTheme]
  static ColorScheme applyJVxColorScheme(ColorScheme colorScheme) {
    bool isDark(Color color) {
      return ThemeData.estimateBrightnessForColor(color) == Brightness.dark;
    }

    if (!isDark(colorScheme.background)) {
      colorScheme = colorScheme.copyWith(background: Colors.grey.shade50);
    }
    if (isDark(colorScheme.onPrimary)) {
      colorScheme = colorScheme.copyWith(onPrimary: JVxColors.LIGHTER_BLACK);
    }
    if (isDark(colorScheme.onPrimaryContainer)) {
      colorScheme = colorScheme.copyWith(onPrimaryContainer: JVxColors.LIGHTER_BLACK);
    }
    if (isDark(colorScheme.onBackground)) {
      colorScheme = colorScheme.copyWith(onBackground: JVxColors.LIGHTER_BLACK);
    }
    if (isDark(colorScheme.onSurface)) {
      colorScheme = colorScheme.copyWith(onSurface: JVxColors.LIGHTER_BLACK);
    }

    return colorScheme;
  }

  /// Applies JVx specific color requirements to the [themeData].
  ///
  /// Same as [applyJVxColorScheme] but for [ThemeData].
  static ThemeData applyJVxTheme(ThemeData themeData) {
    if (ThemeData.estimateBrightnessForColor(themeData.canvasColor) == Brightness.dark) {
      themeData = themeData.copyWith(
        canvasColor: JVxColors.LIGHTER_BLACK,
      );
    }
    if (ThemeData.estimateBrightnessForColor(themeData.cardColor) == Brightness.dark) {
      themeData = themeData.copyWith(
        cardColor: JVxColors.LIGHTER_BLACK,
      );
    }
    if (themeData.textTheme.bodyLarge?.color?.computeLuminance() == 0.0) {
      themeData = themeData.copyWith(
        textTheme: themeData.textTheme.apply(
          bodyColor: JVxColors.LIGHTER_BLACK,
          displayColor: JVxColors.LIGHTER_BLACK,
        ),
      );
    }
    if (themeData.primaryTextTheme.bodyLarge?.color?.computeLuminance() == 0.0) {
      themeData = themeData.copyWith(
        primaryTextTheme: themeData.primaryTextTheme.apply(
          bodyColor: JVxColors.LIGHTER_BLACK,
          displayColor: JVxColors.LIGHTER_BLACK,
        ),
      );
    }
    if (themeData.iconTheme.color?.computeLuminance() == 0.0) {
      themeData = themeData.copyWith(
        iconTheme: themeData.iconTheme.copyWith(
          color: JVxColors.LIGHTER_BLACK,
        ),
      );
    }
    if (themeData.primaryIconTheme.color?.computeLuminance() == 0.0) {
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
