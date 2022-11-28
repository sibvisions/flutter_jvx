import 'package:flutter/material.dart';

import '../../service/api/shared/api_object_property.dart';
import '../../service/api/shared/api_response_names.dart';
import '../../util/parse_util.dart';
import 'api_response.dart';

class ApplicationSettingsResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final bool saveVisible;
  final bool reloadVisible;
  final bool rollbackVisible;
  final bool changePasswordVisible;
  final bool menuBarVisible;
  final bool toolBarVisible;
  final bool homeVisible;
  final bool logoutVisible;
  final bool userSettingsVisible;
  final ApplicationColors? colors;
  final ApplicationColors? darkColors;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApplicationSettingsResponse({
    required this.saveVisible,
    required this.reloadVisible,
    required this.rollbackVisible,
    required this.changePasswordVisible,
    required this.menuBarVisible,
    required this.toolBarVisible,
    required this.homeVisible,
    required this.logoutVisible,
    required this.userSettingsVisible,
    this.colors,
    this.darkColors,
    required super.name,
  });

  ApplicationSettingsResponse.empty()
      : saveVisible = true,
        reloadVisible = true,
        rollbackVisible = true,
        changePasswordVisible = true,
        menuBarVisible = true,
        toolBarVisible = true,
        homeVisible = true,
        logoutVisible = true,
        userSettingsVisible = true,
        colors = null,
        darkColors = null,
        super(name: ApiResponseNames.applicationSettings);

  ApplicationSettingsResponse.fromJson(super.json)
      : saveVisible = json[ApiObjectProperty.save] ?? true,
        reloadVisible = json[ApiObjectProperty.reload] ?? true,
        rollbackVisible = json[ApiObjectProperty.rollback] ?? true,
        changePasswordVisible = json[ApiObjectProperty.changePassword] ?? true,
        menuBarVisible = json[ApiObjectProperty.menuBar] ?? true,
        toolBarVisible = json[ApiObjectProperty.toolBar] ?? true,
        homeVisible = json[ApiObjectProperty.home] ?? true,
        logoutVisible = json[ApiObjectProperty.logout] ?? true,
        userSettingsVisible = json[ApiObjectProperty.userSettings] ?? true,
        colors = json[ApiObjectProperty.colors] == null
            ? null
            : ApplicationColors.fromJson(json[ApiObjectProperty.colors] as Map<String, dynamic>),
        darkColors = json[ApiObjectProperty.colors] == null
            ? null
            : ApplicationColors.fromJson(json[ApiObjectProperty.colors] as Map<String, dynamic>, true),
        super.fromJson();
}

class ApplicationColors {
  static const String DARK_PREFIX = "dark_";

  /// Map with typeName and color as string
  /// e.g. mandatoryBackground, readOnlyBackground, invalidEditorBackground, alternateBackground, ...
  final Color? background;
  final Color? alternateBackground;
  final Color? foreground;
  final Color? activeSelectionBackground;
  final Color? activeSelectionForeground;
  final Color? inactiveSelectionBackground;
  final Color? inactiveSelectionForeground;
  final Color? mandatoryBackground;
  final Color? readOnlyBackground;
  final Color? invalidEditorBackground;

  ApplicationColors({
    this.background,
    this.alternateBackground,
    this.foreground,
    this.activeSelectionBackground,
    this.activeSelectionForeground,
    this.inactiveSelectionBackground,
    this.inactiveSelectionForeground,
    this.mandatoryBackground,
    this.readOnlyBackground,
    this.invalidEditorBackground,
  });

  ApplicationColors.fromJson(Map<String, dynamic> json, [bool isDark = false])
      : background = _handleJsonColor(json, ApiObjectProperty.background, isDark),
        alternateBackground = _handleJsonColor(json, ApiObjectProperty.alternateBackground, isDark),
        foreground = _handleJsonColor(json, ApiObjectProperty.foreground, isDark),
        activeSelectionBackground = _handleJsonColor(json, ApiObjectProperty.activeSelectionBackground, isDark),
        activeSelectionForeground = _handleJsonColor(json, ApiObjectProperty.activeSelectionForeground, isDark),
        inactiveSelectionBackground = _handleJsonColor(json, ApiObjectProperty.inactiveSelectionBackground, isDark),
        inactiveSelectionForeground = _handleJsonColor(json, ApiObjectProperty.inactiveSelectionForeground, isDark),
        mandatoryBackground = _handleJsonColor(json, ApiObjectProperty.mandatoryBackground, isDark),
        readOnlyBackground = _handleJsonColor(json, ApiObjectProperty.readOnlyBackground, isDark),
        invalidEditorBackground = _handleJsonColor(json, ApiObjectProperty.invalidEditorBackground, isDark);

  static Color? _handleJsonColor(Map<String, dynamic> pJson, String pPropertyName, bool pIsDark) {
    String propertyName = pPropertyName;
    String darkPropertyName = DARK_PREFIX + propertyName;

    if (pIsDark) {
      if (pJson.keys.contains(darkPropertyName)) {
        return ColorConverter.fromJson(pJson[darkPropertyName]);
      } else {
        Color? lightColor = ColorConverter.fromJson(pJson[pPropertyName]);
        Color? darkColor;
        if (lightColor != null) {
          HSVColor hsvColor = HSVColor.fromColor(lightColor);
          hsvColor = hsvColor.withSaturation((hsvColor.saturation + 0.1).clamp(0.0, 1.0));
          hsvColor = hsvColor.withValue((hsvColor.value - 0.2).clamp(0.0, 1.0));

          darkColor = hsvColor.toColor();
        }
        return darkColor;
      }
    } else {
      return ColorConverter.fromJson(pJson[pPropertyName]);
    }
  }
}

abstract class ColorConverter {
  static Color? fromJson(String? value) {
    if (value == null) return null;
    String sColor = value.toString();

    sColor = sColor.split(";").first;
    return ParseUtil.parseHexColor(sColor);
  }

  static String toJson(Color object) => "#${object.value.toRadixString(16)}";
}
