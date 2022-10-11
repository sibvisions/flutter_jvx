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

  /// map with typeName and color as string
  /// e.g. mandatoryBackground, readOnlyBackground, invalidEditorBackground, alternateBackground, ...
  late final Color? background;
  late final Color? alternateBackground;
  late final Color? foreground;
  late final Color? activeSelectionBackground;
  late final Color? activeSelectionForeground;
  late final Color? inactiveSelectionBackground;
  late final Color? inactiveSelectionForeground;
  late final Color? mandatoryBackground;
  late final Color? readOnlyBackground;
  late final Color? invalidEditorBackground;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
        background = null,
        alternateBackground = null,
        foreground = null,
        activeSelectionBackground = null,
        activeSelectionForeground = null,
        inactiveSelectionBackground = null,
        inactiveSelectionForeground = null,
        mandatoryBackground = null,
        readOnlyBackground = null,
        invalidEditorBackground = null,
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
        super.fromJson() {
    applyColors(json[ApiObjectProperty.colors] ?? {});
  }

  void applyColors(Map<String, dynamic> pJson) {
    background = getColor(pJson[ApiObjectProperty.background]);
    alternateBackground = getColor(pJson[ApiObjectProperty.alternateBackground]);
    foreground = getColor(pJson[ApiObjectProperty.foreground]);
    activeSelectionBackground = getColor(pJson[ApiObjectProperty.activeSelectionBackground]);
    activeSelectionForeground = getColor(pJson[ApiObjectProperty.activeSelectionForeground]);
    inactiveSelectionBackground = getColor(pJson[ApiObjectProperty.inactiveSelectionBackground]);
    inactiveSelectionForeground = getColor(pJson[ApiObjectProperty.inactiveSelectionForeground]);
    mandatoryBackground = getColor(pJson[ApiObjectProperty.mandatoryBackground]);
    readOnlyBackground = getColor(pJson[ApiObjectProperty.readOnlyBackground]);
    invalidEditorBackground = getColor(pJson[ApiObjectProperty.invalidEditorBackground]);
  }

  Color? getColor(dynamic pValue) {
    String? sColor = pValue?.toString();

    sColor = sColor?.split(";").first;
    return ParseUtil.parseHexColor(sColor);
  }
}
