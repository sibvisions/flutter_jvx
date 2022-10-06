import '../../service/api/shared/api_object_property.dart';
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
  final dynamic colors;

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
        colors = {},
        super.fromJson(pJson: {}, originalRequest: "");

  ApplicationSettingsResponse.fromJson({required Map<String, dynamic> pJson, required Object originalRequest})
      : saveVisible = pJson[ApiObjectProperty.save] ?? true,
        reloadVisible = pJson[ApiObjectProperty.reload] ?? true,
        rollbackVisible = pJson[ApiObjectProperty.rollback] ?? true,
        changePasswordVisible = pJson[ApiObjectProperty.changePassword] ?? true,
        menuBarVisible = pJson[ApiObjectProperty.menuBar] ?? true,
        toolBarVisible = pJson[ApiObjectProperty.toolBar] ?? true,
        homeVisible = pJson[ApiObjectProperty.home] ?? true,
        logoutVisible = pJson[ApiObjectProperty.logout] ?? true,
        userSettingsVisible = pJson[ApiObjectProperty.userSettings] ?? true,
        colors = pJson[ApiObjectProperty.colors] ?? {},
        super.fromJson(pJson: pJson, originalRequest: originalRequest);
}
