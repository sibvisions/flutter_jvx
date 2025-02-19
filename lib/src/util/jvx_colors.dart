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

import '../../flutter_jvx.dart';

abstract class JVxColors {
  static Color blue = ColorScheme.fromSeed(seedColor: Colors.blue).primary;
  static const Color WHITE = Colors.white24;

  static const Color LIGHTER_BLACK = Color(0xFF424242);
  static const Color DARKER_WHITE = Color(0xFFFAFAFA);

  static const Color TABLE_VERTICAL_DIVIDER = Color(0xFFBDBDBD);
  static const Color TABLE_FOCUS_REACT = Color(0xFF666666);
  static const Color COMPONENT_BORDER = Color(0xFF999999);
  static const Color COMPONENT_DISABLED = Color(0xFFBDBDBD);
  static const Color COMPONENT_DISABLED_LIGHTER = Color(0xFFE6E6E6);
  static const Color TEXT_HINT_LABEL_COLOR = Color(0xFF999999);
  static const Color STANDARD_BORDER = Color(0xFF999999);

  /// The default border radius
  static const double BORDER_RADIUS = 5;

  /// Specifically requested color mix.
  static Color dividerColor(ThemeData theme) {
    return theme.colorScheme.onPrimary.withAlpha(Color.getAlphaFromOpacity(0.15));
  }

  /// Whether the theme of [context] is in light mode
  static bool isLightTheme([BuildContext? context]) {
    if (context != null) {
      return isLight(Theme.of(context));
    }
    else{
      return isLight(Theme.of(FlutterUI.getCurrentContext()!));
    }
  }

  /// Whether the [theme] is in light mode
  static bool isLight([ThemeData? theme]) {
    if (theme != null) {
      return theme.brightness == Brightness.light;
    }
    else {
      return Theme.of(FlutterUI.getCurrentContext()!).brightness == Brightness.light;
    }
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

    //temporary color scheme to get the "real" primary "calculated" color
    ColorScheme csTemp = ColorScheme.fromSeed(seedColor: seedColor, brightness: selectedBrightness);

    bool isSelectedLight = selectedBrightness == Brightness.light;

    //we don't use fixed primary color in dark mode, so we have to check the calculated primary color for brightness
    //to get the correct foreground colors
    bool isSeedLight = ThemeData.estimateBrightnessForColor(seedColor) == Brightness.light
                       || (!isSelectedLight && ThemeData.estimateBrightnessForColor(csTemp.primary) == Brightness.light);

    if (useFixedPrimary) {
      colorScheme = ColorScheme.fromSeed(
        seedColor: seedColor,
        primary: isSelectedLight ? seedColor : null,
        onPrimary: isSeedLight ? JVxColors.LIGHTER_BLACK : Colors.white,
        secondary: isSelectedLight ? JVxColors.darken(seedColor, 0.1) : JVxColors.lighten(seedColor, 0.1),
        onSecondary: isSeedLight ? JVxColors.LIGHTER_BLACK : Colors.white,
        onTertiary: isSeedLight ? JVxColors.LIGHTER_BLACK : Colors.white,
        brightness: selectedBrightness,
        surface: isSelectedLight ? Colors.grey.shade50 : Colors.grey.shade900,
      );
    } else {
      colorScheme = ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: selectedBrightness,
        surface: isSelectedLight ? Colors.grey.shade50 : Colors.grey.shade900,
      );
    }

    var themeData = ThemeData.from(colorScheme: colorScheme, useMaterial3: true);

    ElevatedButtonThemeData evbTheme = ElevatedButtonThemeData(style: ElevatedButton.styleFrom(foregroundColor: isSeedLight ? JVxColors.LIGHTER_BLACK : Colors.white,
        backgroundColor: colorScheme.primary,
        iconColor: isSeedLight ? JVxColors.LIGHTER_BLACK : Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(BORDER_RADIUS)))));

    OutlinedButtonThemeData otbTheme = OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
        foregroundColor: isSeedLight ? JVxColors.LIGHTER_BLACK : Colors.white,
        iconColor: isSeedLight ? JVxColors.LIGHTER_BLACK : Colors.white));

    themeData = themeData.copyWith(
        appBarTheme: AppBarTheme(backgroundColor: isSelectedLight ? colorScheme.primary : colorScheme.surface,
                                 foregroundColor: isSelectedLight ? (isSeedLight ? JVxColors.LIGHTER_BLACK : Colors.white) : themeData.textTheme.labelSmall!.color),
        cardTheme: CardTheme(surfaceTintColor: isSelectedLight ? Colors.white : Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
        dividerTheme: DividerThemeData(color: dividerColor(themeData)),
        dialogTheme: DialogTheme(backgroundColor: isSelectedLight ? Colors.grey.shade50 : Colors.grey[850],
            surfaceTintColor: isSelectedLight ? Colors.grey.shade50 : Colors.grey[850],
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BORDER_RADIUS))),
//        dialogBackgroundColor: isSelectedLight ? Colors.white : Colors.grey[850],
        textButtonTheme: TextButtonThemeData(style: ButtonStyle(foregroundColor: WidgetStateProperty.all(isSelectedLight ? colorScheme.primary : themeData.textTheme.labelSmall!.color),
                                                                overlayColor: WidgetStateProperty.all(isSelectedLight ? null : JVxColors.WHITE))),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(shape: CircleBorder(side: BorderSide(width: 0, style: BorderStyle.none))),
        elevatedButtonTheme: evbTheme,
        outlinedButtonTheme: otbTheme,
        datePickerTheme: DatePickerThemeData(backgroundColor: isSelectedLight ? Colors.grey.shade50 : Colors.grey[850],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BORDER_RADIUS))),
        timePickerTheme: TimePickerThemeData(backgroundColor: isSelectedLight ? Colors.grey.shade50 : Colors.grey[850],
            dialBackgroundColor: isSelectedLight ? Colors.grey.shade50 : Colors.grey[850],
            hourMinuteShape: const OutlineInputBorder(
              //same as in text field widget
                borderSide: BorderSide(
                  color: COMPONENT_BORDER,
                )),
            hourMinuteColor: themeData.inputDecorationTheme.fillColor ?? themeData.colorScheme.surface,
            dayPeriodColor: isSelectedLight ? JVxColors.lighten(seedColor, 0.3) : JVxColors.darken(seedColor, 0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BORDER_RADIUS))),
        typography: Typography.material2014()
    );

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
        primaryIconTheme: themeData.primaryIconTheme.copyWith(
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

    if (hsl.lightness - amount >= 0) {
      final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

      return hslDark.toColor();
    }
    else {
      return color;
    }
  }

  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);

    if (hsl.lightness + amount <= 1) {
      final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 2.0));

      return hslLight.toColor();
    }
    else {
      return color;
    }
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
