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

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import '../../config/app_config.dart';
import '../../model/config/user/user_info.dart';
import '../../model/request/api_startup_request.dart';
import '../../model/response/download_images_response.dart';
import '../../model/response/download_style_response.dart';
import '../file/file_manager.dart';
import '../service.dart';
import 'shared/config_handler.dart';

/// Allows to read user settings, update user settings, or listen
/// to user settings changes.
abstract class IConfigService implements Service {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns the singleton instance.
  factory IConfigService() => services<IConfigService>();

  /// Loads the initial configuration.
  ///
  /// If [devConfig] is true, this call removes all saved values for [ServerConfig]
  /// which would prevent the default config to be used.
  Future<void> loadConfig(AppConfig pAppConfig, [bool devConfig = false]);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Helper-methods for non-persistent fields
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns the currently in use [ConfigHandler] instance.
  ///
  /// It is recommended to use the provided methods instead of directly accessing the [ConfigHandler].
  ConfigHandler getConfigHandler();

  /// Returns the current [IFileManager] in use.
  IFileManager getFileManager();

  /// Returns the platform locale using [Platform.localeName].
  String getPlatformLocale();

  /// Returns the cached platform timezone (retrieved via [FlutterTimezone.getLocalTimezone]).
  String? getPlatformTimeZone();

  /// Returns the initial configured app config.
  ///
  /// To get up to date values, use their respective getters:
  /// * [baseUrl]
  /// * [appName]
  /// * [username]
  /// * [password]
  AppConfig? getAppConfig();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Persisting methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns the current [ThemeMode] preference.
  ///
  /// Returns [ThemeMode.system] if none is configured.
  ValueListenable<ThemeMode> get themePreference;

  /// Sets the current [ThemeMode] preference.
  ///
  /// If [themeMode] is [ThemeMode.system], the preference will be set to `null`.
  Future<void> updateThemePreference(ThemeMode themeMode);

  /// Returns the configured max. picture resolution.
  ///
  /// This is being used to limit the resolution of pictures taken via the in-app camera.
  ValueListenable<int?> get pictureResolution;

  /// Sets the max. picture resolution.
  Future<void> updatePictureResolution(int pictureResolution);

  /// Returns the last opened app.
  ValueListenable<bool> get singleAppMode;

  /// Sets the last opened app.
  Future<void> updateSingleAppMode(bool? singleAppMode);

  /// Returns the default app.
  ValueListenable<String?> get defaultApp;

  /// Sets the default app.
  Future<void> updateDefaultApp(String? appId);

  /// Returns the last opened app.
  ValueListenable<String?> get lastApp;

  /// Sets the last opened app.
  Future<void> updateLastApp(String? appId);

  /// Returns the configured privacy policy.
  ValueListenable<Uri?> get privacyPolicy;

  /// Sets the privacy policy.
  Future<void> updatePrivacyPolicy(Uri? policy);

  /// Returns the id of the current app.
  ValueListenable<String?> get currentApp;

  /// Sets the name of the current app.
  Future<void> updateCurrentApp(String? appId);

  /// Returns the name of the current app.
  ValueListenable<String?> get appName;

  /// Sets the name of the current app.
  Future<void> updateAppName(String? name);

  /// Returns the saved base url.
  ///
  /// This is either:
  /// * The user entered base url.
  /// * The [ServerConfig.baseUrl] from the configured [AppConfig].
  ValueListenable<Uri?> get baseUrl;

  /// Sets the base url.
  ///
  /// Overrides the base url from [AppConfig.serverConfigs].
  Future<void> updateBaseUrl(Uri? baseUrl);

  /// Returns the last saved username or the configured one from [AppConfig.serverConfigs].
  ValueListenable<String?> get username;

  /// Sets the saved username.
  ///
  /// Overrides the username from [AppConfig.serverConfigs].
  Future<void> updateUsername(String? username);

  /// Returns the last saved password or the configured one from [AppConfig.serverConfigs].
  ValueListenable<String?> get password;

  /// Sets the saved password.
  ///
  /// Overrides the password from [AppConfig.serverConfigs].
  Future<void> updatePassword(String? password);

  /// Returns the saved title.
  ValueListenable<String?> get title;

  /// Sets the title.
  ///
  /// Overrides the title from [AppConfig.serverConfigs].
  Future<void> updateTitle(String? title);

  /// Returns the saved icon.
  ValueListenable<String?> get icon;

  /// Sets the icon.
  ///
  /// Overrides the icon from [AppConfig.serverConfigs].
  Future<void> updateIcon(String? icon);

  /// Whether this app config is locked.
  ValueListenable<bool?> get locked;

  /// Whether this app config is hidden.
  ValueListenable<bool?> get parametersHidden;

  /// Returns the last saved authKey, which will be used on [ApiStartupRequest].
  ValueListenable<String?> get authKey;

  /// Sets the authKey.
  Future<void> updateAuthKey(String? pAuthKey);

  /// Returns version of the current app.
  ValueListenable<String?> get version;

  /// Sets the version of the current app.
  Future<void> updateVersion(String? pVersion);

  /// Returns info about the current user.
  ValueListenable<UserInfo?> get userInfo;

  /// Sets the current user info.
  Future<void> updateUserInfo({UserInfo? pUserInfo, Map<String, dynamic>? pJson});

  /// Returns the language which should be used to translate text shown to the user.
  ///
  /// This is either:
  /// * The server set language (which in most cases the same as we send in the startup).
  /// * The user chosen language.
  /// * The platform locale (determined by [getPlatformLocale]).
  String getLanguage();

  /// Returns the application language code returned by the server.
  ///
  /// Returns `null` before initial startup.
  ValueListenable<String?> get applicationLanguage;

  /// Sets the application language code returned by the server.
  Future<void> updateApplicationLanguage(String? pLanguage);

  /// Returns the user defined language code.
  ///
  /// To get the really used language, use [getLanguage].
  ValueListenable<String?> get userLanguage;

  /// Set the user defined language code.
  Future<void> updateUserLanguage(String? pLanguage);

  /// Returns all currently supported languages by this application.
  ValueListenable<Set<String>> get supportedLanguages;

  /// Refreshes the supported languages by checking the local translation folder.
  ///
  /// See also:
  /// * [supportedLanguages]
  Future<void> reloadSupportedLanguages();

  /// Returns the timezone which should be used to calculate dates/times shown to the user.
  ///
  /// This is either:
  /// * The server defined timezone (which in most cases the same as we send in the [ApiStartupRequest]).
  /// * The platform timezone (determined by [getPlatformTimeZone]).
  String getTimezone();

  /// Returns the application timezone returned by the server.
  ValueListenable<String?> get applicationTimeZone;

  /// Set the application defined timezone.
  Future<void> updateApplicationTimeZone(String? timeZoneCode);

  /// Returns the last saved app style.
  ///
  /// Use [AppStyle] instead when used in Widgets.
  ///
  /// See also:
  /// * [AppStyle]
  /// * [updateApplicationStyle]
  ValueListenable<Map<String, String>?> get applicationStyle;

  /// Sets the app style.
  ///
  /// Calls the style callbacks.
  /// This will also be persisted for offline usage.
  ///
  /// See also:
  /// * [DownloadStyleResponse]
  Future<void> updateApplicationStyle(Map<String, String>? pAppStyle);

  /// Returns the scaling multiplier for server sent sizes
  double getScaling();

  /// Returns if the app is currently in offline mode.
  ValueListenable<bool> get offline;

  /// Sets the offline mode.
  Future<void> updateOffline(bool pOffline);

  /// Returns the screen to which the offline data has to be synced back.
  ///
  /// Is only available while being offline ([offline]).
  /// Normally this is the same as the last open screen when going offline.
  ValueListenable<String?> get offlineScreen;

  /// Sets the screen to which the offline data has to be synced back.
  Future<void> updateOfflineScreen(String pWorkscreen);

  // ------------------------------

  /// Returns a map of all custom parameters which are sent on every [ApiStartupRequest].
  ///
  /// See also:
  /// * [ApiStartupRequest]
  Map<String, dynamic> getCustomStartupProperties();

  /// Set a custom startup parameter.
  ///
  /// See also:
  /// * [getCustomStartupProperties]
  void updateCustomStartupProperties(String pKey, dynamic pValue);

  /// Register a callback that will be called when the locally saved images change.
  ///
  /// See also:
  /// * [DownloadImagesResponse]
  void registerImagesCallback(Function() pCallback);

  /// Dispose an image callback.
  void disposeImagesCallback(Function() pCallback);

  /// Dispose all image callbacks.
  void disposeImagesCallbacks();

  /// Triggers all image callbacks.
  void imagesChanged();
}
