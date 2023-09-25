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

import '../../../model/config/user/user_info.dart';
import '../../../model/request/api_startup_request.dart';

/// Handles the access and storage of config.
///
/// Config handlers are used to store & access all
/// configurable data and session based data.
abstract class ConfigHandler {
  /// Retrieves the [ThemeMode] preference.
  Future<ThemeMode?> themePreference();

  /// Sets the current [ThemeMode] preference.
  Future<void> updateThemePreference(ThemeMode? themeMode);

  /// Retrieves the configured max. picture resolution.
  Future<int?> pictureResolution();

  /// Sets the max. picture resolution.
  Future<void> updatePictureResolution(int pictureResolution);

  /// Whether the single app mode is active.
  Future<bool> singleAppMode();

  /// Sets the single app mode.
  Future<void> updateSingleAppMode(bool? singleAppMode);

  /// Retrieves the default app.
  Future<String?> defaultApp();

  /// Sets the default app.
  Future<void> updateDefaultApp(String? appId);

  /// Retrieves the last opened app.
  Future<String?> lastApp();

  /// Sets the last opened app.
  Future<void> updateLastApp(String? appId);

  /// Retrieves the last opened app.
  Future<String?> privacyPolicy();

  /// Sets the last opened app.
  Future<void> updatePrivacyPolicy(String? policy);

  /// Retrieves a global value.
  Future<T?> getValue<T>(String name);

  /// Sets a global value.
  ///
  /// `null` removes the value.
  Future<bool> setValue<T>(String name, T? value);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Methods used to manage preferences that are saved under the app key
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Retrieves all known app keys.
  Future<Set<String>> getAppKeys();

  /// Moves every preference that satisfies [test] to [newKey].
  Future<void> updateWhere(bool Function(String key) test, String newKey);

  /// Moves every preference referenced by [key] to [newKey].
  Future<void> updateAppKey(String key, String newKey);

  /// Removes every preference that satisfies [test].
  Future<void> removeWhere(bool Function(String key) test);

  /// Removes every preference referenced by [key].
  Future<void> removeAppKeys(String key, {bool Function(String key)? filter});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Preferences that are saved under the app key
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Retrieves the id of the current app.
  Future<String?> currentApp();

  /// Sets the id of the current app.
  Future<void> updateCurrentApp(String? appId);

  /// Retrieves the name of the current app.
  Future<String?> appName();

  /// Sets the name of the current app.
  Future<void> updateAppName(String? appName);

  /// Retrieves the saved base URL.
  Future<String?> baseUrl();

  /// Sets the base URL for the current app.
  Future<void> updateBaseUrl(String? baseUrl);

  /// Retrieves the saved username.
  Future<String?> username();

  /// Sets the saved username for the current app.
  Future<void> updateUsername(String? username);

  /// Retrieves the saved password.
  Future<String?> password();

  /// Sets the saved password for the current app.
  Future<void> updatePassword(String? password);

  /// Retrieves the saved title.
  Future<String?> title();

  /// Sets the title for the current app.
  Future<void> updateTitle(String? title);

  /// Retrieves the saved icon.
  Future<String?> icon();

  /// Sets the icon for the current app.
  Future<void> updateIcon(String? icon);

  /// Retrieves the saved authKey, which will be used on [ApiStartupRequest] headers.
  Future<String?> authKey();

  /// Sets the saved authKey for the current app.
  Future<void> updateAuthKey(String? authKey);

  /// Retrieves version of the current app.
  Future<String?> version();

  /// Sets the version of the current app.
  Future<void> updateVersion(String? version);

  /// Retrieves info about the current user.
  Future<UserInfo?> userInfo();

  /// Sets the current user info.
  Future<void> updateUserInfo(Map<String, dynamic>? json);

  /// Retrieves whether the language is customised and therefore fixed by the server.
  Future<bool?> customLanguage();

  /// Sets whether the language is customised and therefore fixed.
  Future<void> updateCustomLanguage(bool? customLanguage);

  /// Retrieves the user defined language code.
  Future<String?> userLanguage();

  /// Set the user defined language code.
  Future<void> updateUserLanguage(String? language);

  /// Retrieves the application language returned by the server.
  Future<String?> applicationLanguage();

  /// Set the application defined language.
  Future<void> updateApplicationLanguage(String? language);

  /// Retrieves the application timezone returned by the server.
  Future<String?> applicationTimeZone();

  /// Set the application defined timezone.
  Future<void> updateApplicationTimeZone(String? timeZoneCode);

  /// Retrieves the last saved app style.
  Future<Map<String, String>?> applicationStyle();

  /// Sets the app style.
  Future<void> updateApplicationStyle(Map<String, String>? appStyle);

  /// Retrieves if the app is currently in offline mode.
  Future<bool> offline();

  /// Sets the offline mode.
  Future<void> updateOffline(bool offline);

  /// Retrieves the saved offline screen.
  Future<String?> offlineScreen();

  /// Sets the offline screen.
  Future<void> updateOfflineScreen(String workscreen);
}
