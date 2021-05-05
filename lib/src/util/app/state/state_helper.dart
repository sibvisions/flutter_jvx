import 'package:flutter/material.dart';

import '../../../../injection_container.dart';
import '../../../models/api/response_objects/application_meta_data_response_object.dart';
import '../../../models/api/response_objects/application_parameters_response_object.dart';
import '../../../models/api/response_objects/application_style/application_style_response_object.dart';
import '../../../models/api/response_objects/device_status_response_object.dart';
import '../../../models/api/response_objects/language_response_object.dart';
import '../../../models/api/response_objects/menu/menu_response_object.dart';
import '../../../models/api/response_objects/user_data_response_object.dart';
import '../../../models/state/app_state.dart';
import '../../../models/state/application_parameters.dart';
import '../../../services/local/locale/supported_locale_manager.dart';
import '../../../services/local/shared_preferences/shared_preferences_manager.dart';
import '../../../services/remote/cubit/api_cubit.dart';
import '../../color/get_color_from_app_style.dart';
import '../../download/file_config.dart';
import '../../theme/theme_manager.dart';
import '../../translation/app_localizations.dart';
import '../../translation/translation_config.dart';

class StateHelper {
  static void updateAppStateWithLocalData(
      SharedPreferencesManager manager, AppState appState) {
    if (manager.possibleTranslations != null) {
      appState.translationConfig.possibleTranslations =
          manager.possibleTranslations!;
    }

    if (manager.savedImages != null) {
      appState.fileConfig.images = manager.savedImages!;
    }

    if (manager.userData != null) {
      appState.userData = manager.userData;
    }

    if (manager.picSize != null) {
      appState.picSize = manager.picSize!;
    }

    // If appState's mobileOnly is false then update it with local data
    // because appState's mobileOnly could be set from a custom application
    // outside scope.
    if (!appState.mobileOnly) {
      appState.mobileOnly = manager.mobileOnly;
    }

    // Same here.
    if (!appState.webOnly) {
      appState.webOnly = manager.webOnly;
    }

    if (manager.language != null && manager.language!.isNotEmpty) {
      appState.language =
          LanguageResponseObject(name: 'language', language: manager.language!);
    }

    if (appState.translationConfig.possibleTranslations.isNotEmpty) {
      appState.translationConfig.supportedLocales = List<Locale>.from(
          appState.translationConfig.possibleTranslations.keys.map((key) {
        if (key.contains('_'))
          return Locale(key.substring(key.indexOf('_') + 1, key.indexOf('.')));
        else
          return Locale('en');
      }));

      WidgetsBinding.instance!.addPostFrameCallback((_) =>
          sl<SupportedLocaleManager>().value =
              appState.translationConfig.supportedLocales);
    }
  }

  static void updateAppStateWithStartupResponse(
      AppState appState, ApiResponse response) {
    if (response.hasObject<ApplicationMetaDataResponseObject>()) {
      appState.applicationMetaData =
          response.getObjectByType<ApplicationMetaDataResponseObject>();
    }

    if (response.hasObject<LanguageResponseObject>()) {
      LanguageResponseObject languageResponseObject =
          response.getObjectByType<LanguageResponseObject>()!;

      appState.language = languageResponseObject;
      AppLocalizations.load(Locale(languageResponseObject.language));
    }

    if (response.hasObject<DeviceStatusResponseObject>()) {
      appState.deviceStatus =
          response.getObjectByType<DeviceStatusResponseObject>();
    }

    if (response.hasObject<UserDataResponseObject>()) {
      appState.userData = response.getObjectByType<UserDataResponseObject>();
    }

    if (response.hasObject<MenuResponseObject>()) {
      appState.menuResponseObject =
          response.getObjectByType<MenuResponseObject>()!;
    }
  }

  static void updateLocalDataWithStartupResponse(
      SharedPreferencesManager manager, ApiResponse response) {
    if (response.hasObject<UserDataResponseObject>()) {
      manager.userData = response.getObjectByType<UserDataResponseObject>();
    }

    if (response.hasObject<LanguageResponseObject>()) {
      manager.language =
          response.getObjectByType<LanguageResponseObject>()!.language;
    }

    if (response.hasObject<ApplicationMetaDataResponseObject>()) {
      ApplicationMetaDataResponseObject applicationMetaData =
          response.getObjectByType<ApplicationMetaDataResponseObject>()!;

      manager.applicationMetaData = applicationMetaData;

      if (manager.appVersion != applicationMetaData.version) {
        manager.previousAppVersion = manager.appVersion;
        manager.appVersion = applicationMetaData.version;
      }
    }
  }

  static void updateAppStateAndLocalDataWithApplicationStyleResponse(
      AppState appState,
      SharedPreferencesManager manager,
      ApiResponse response) {
    if (response.hasObject<ApplicationStyleResponseObject>()) {
      ApplicationStyleResponseObject applicationStyle =
          response.getObjectByType<ApplicationStyleResponseObject>()!;

      appState.applicationStyle = applicationStyle;

      manager.applicationStyle = applicationStyle;

      // Setting theme for the whole application.
      sl<ThemeManager>().value = ThemeData(
        primaryColor: appState.applicationStyle!.themeColor,
        primarySwatch: getColorFromAppStyle(appState.applicationStyle!),
        brightness: Brightness.light,
      );
    }
  }

  static void clearServerData(
      AppState appState, SharedPreferencesManager manager) {
    // Remove App State data

    appState.translationConfig = TranslationConfig();
    appState.fileConfig = FileConfig();
    appState.applicationMetaData = null;
    appState.applicationStyle = null;
    appState.currentMenuComponentId = null;
    appState.menuResponseObject = MenuResponseObject.empty();
    appState.parameters = ApplicationParameters();
    appState.userData = null;

    // Remove shared preferences data

    manager.setSyncLoginData(username: null, password: null);
    manager.possibleTranslations = null;
    manager.applicationStyle = null;
    manager.applicationStyleHash = null;
    manager.appVersion = null;
    manager.previousAppVersion = null;
    manager.authKey = null;
    manager.offlineUsername = null;
    manager.offlinePassword = null;
    manager.savedImages = null;
    manager.userData = null;
  }

  static void updateAppStateAndLocalDataWithResponse(AppState appState,
      SharedPreferencesManager manager, ApiResponse response) {
    if (response.hasObject<MenuResponseObject>()) {
      appState.menuResponseObject =
          response.getObjectByType<MenuResponseObject>()!;
    }

    if (response.hasObject<UserDataResponseObject>()) {
      UserDataResponseObject userData =
          response.getObjectByType<UserDataResponseObject>()!;
      appState.userData = userData;
      manager.userData = userData;
    }

    if (response.hasObject<DeviceStatusResponseObject>()) {
      appState.deviceStatus =
          response.getObjectByType<DeviceStatusResponseObject>();
    }

    if (response.hasObject<LanguageResponseObject>()) {
      LanguageResponseObject language =
          response.getObjectByType<LanguageResponseObject>()!;
      appState.language = language;
      manager.language = language.language;
      AppLocalizations.load(Locale(language.language));
    }

    if (response.hasObject<ApplicationMetaDataResponseObject>()) {
      ApplicationMetaDataResponseObject applicationMetaData =
          response.getObjectByType<ApplicationMetaDataResponseObject>()!;
      appState.applicationMetaData = applicationMetaData;
      manager.applicationMetaData = applicationMetaData;
    }

    if (response.hasObject<ApplicationParametersResponseObject>()) {
      appState.parameters.updateFromResponseObject(
          response.getObjectByType<ApplicationParametersResponseObject>()!);
    }
  }
}
