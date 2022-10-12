import 'dart:ui';

import '../../../util/parse_util.dart';
import '../../service/api/shared/api_object_property.dart';
import '../../service/api/shared/api_response_names.dart';
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
    required super.name,
    required super.originalRequest,
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
        super(name: ApiResponseNames.applicationSettings, originalRequest: "");

  ApplicationSettingsResponse.fromJson({required super.json, required super.originalRequest})
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
        super.fromJson();
}

class ApplicationColors {
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

  ApplicationColors.fromJson(Map<String, dynamic> json)
      : background = ColorConverter.fromJson(json[ApiObjectProperty.background]),
        alternateBackground = ColorConverter.fromJson(json[ApiObjectProperty.alternateBackground]),
        foreground = ColorConverter.fromJson(json[ApiObjectProperty.foreground]),
        activeSelectionBackground = ColorConverter.fromJson(json[ApiObjectProperty.activeSelectionBackground]),
        activeSelectionForeground = ColorConverter.fromJson(json[ApiObjectProperty.activeSelectionForeground]),
        inactiveSelectionBackground = ColorConverter.fromJson(json[ApiObjectProperty.inactiveSelectionBackground]),
        inactiveSelectionForeground = ColorConverter.fromJson(json[ApiObjectProperty.inactiveSelectionForeground]),
        mandatoryBackground = ColorConverter.fromJson(json[ApiObjectProperty.mandatoryBackground]),
        readOnlyBackground = ColorConverter.fromJson(json[ApiObjectProperty.readOnlyBackground]),
        invalidEditorBackground = ColorConverter.fromJson(json[ApiObjectProperty.invalidEditorBackground]);
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
