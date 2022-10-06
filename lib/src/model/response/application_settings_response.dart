import 'dart:ui';

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
  Map<String, Color> colors = {};

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
        super.fromJson(pJson: {ApiObjectProperty.name: ApiResponseNames.applicationSettings}, originalRequest: "");

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
        super.fromJson(pJson: pJson, originalRequest: originalRequest) {
    // dynamic x = pJson[ApiObjectProperty.colors];
    // for (dynamic y in x) {
    //   log(y.toString());
    // }

    // log(x.toString());
    //colors = pJson[ApiObjectProperty.colors] ?? {};
  }
}
