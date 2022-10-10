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

  /// The static constant for control background color. */
  static const String BACKGROUND = "background";

  /// The static constant for control alternate background color. */
  static const String ALTERNATE_BACKGROUND = "alternatebackground";

  /// The static constant for control foreground color. */
  static const String FOREGROUND = "foreground";

  /// The static constant for control active selection background color. */
  static const String ACTIVE_SELECTION_BACKGROUND = "activeselectionbackground";

  /// The static constant for control active selection foreground color. */
  static const String ACTIVE_SELECTION_FOREGROUND = "activeselectionforeground";

  /// The static constant for control inactive selection background color. */
  static const String INACTIVE_SELECTION_BACKGROUND = "inactiveselectionbackground";

  /// The static constant for control inactive selection foreground color. */
  static const String INACTIVE_SELECTION_FOREGROUND = "inactiveselectionforeground";

  /// The static constant for control mandatory background color. */
  static const String MANDATORY_BACKGROUND = "mandatorybackground";

  /// The static constant for control read only background color. */
  static const String READ_ONLY_BACKGROUND = "readonlybackground";

  /// The static constant for control read only background color. */
  static const String INVALID_EDITOR_BACKGROUND = "invalideditorbackground";

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
    background = getColor(pJson[BACKGROUND]);
    alternateBackground = getColor(pJson[ALTERNATE_BACKGROUND]);
    foreground = getColor(pJson[FOREGROUND]);
    activeSelectionBackground = getColor(pJson[ACTIVE_SELECTION_BACKGROUND]);
    activeSelectionForeground = getColor(pJson[ACTIVE_SELECTION_FOREGROUND]);
    inactiveSelectionBackground = getColor(pJson[INACTIVE_SELECTION_BACKGROUND]);
    inactiveSelectionForeground = getColor(pJson[INACTIVE_SELECTION_FOREGROUND]);
    mandatoryBackground = getColor(pJson[MANDATORY_BACKGROUND]);
    readOnlyBackground = getColor(pJson[READ_ONLY_BACKGROUND]);
    invalidEditorBackground = getColor(pJson[INVALID_EDITOR_BACKGROUND]);
  }

  Color? getColor(dynamic pValue) {
    String? sColor = pValue?.toString();

    sColor = sColor?.split(";").first;
    return ParseUtil.parseHexColor(sColor);
  }
}
