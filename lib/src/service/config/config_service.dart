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

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/server_config.dart';
import '../../model/config/user/user_info.dart';
import '../../model/request/api_startup_request.dart';

/// Stores all config and session based data.
///
/// Config service is used to store & access all configurable data,
/// also stores session based data such as clientId and userData.
class ConfigService {
  final SharedPreferences _sharedPrefs;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ConfigService.create({
    required SharedPreferences sharedPrefs,
  }) : _sharedPrefs = sharedPrefs;

  /// Returns the current in use [SharedPreferences] instance.
  SharedPreferences getSharedPreferences() {
    return _sharedPrefs;
  }

  Set<String> getAppNames() {
    RegExp regExp = RegExp(r'(\w+)\.\w+');
    return _sharedPrefs
        .getKeys()
        .map((element) => regExp.allMatches(element))
        .where((e) => e.isNotEmpty)
        .map((e) => e.first[1].toString())
        .sorted((a, b) => b.compareTo(a))
        .toSet();
  }

  Future<ServerConfig> getApp(String appName) async {
    String prefix = appName;
    String? baseUrl = _sharedPrefs.getString("$prefix.baseUrl");
    String? defaultAppName = await defaultApp();
    return ServerConfig(
      appName: appName,
      baseUrl: baseUrl != null ? Uri.parse(baseUrl) : null,
      username: _sharedPrefs.getString("$prefix.username"),
      password: _sharedPrefs.getString("$prefix.password"),
      title: _sharedPrefs.getString("$prefix.title"),
      icon: _sharedPrefs.getString("$prefix.icon"),
      isDefault: defaultAppName == null ? null : appName == defaultAppName,
    );
  }

  String? getAppVersion(String appName) {
    return _sharedPrefs.getString("$appName.version");
  }

  Map<String, String>? getAppStyle(String appName) {
    String? jsonMap = _sharedPrefs.getString("$appName.applicationStyle");
    return (jsonMap != null ? Map<String, String>.from(jsonDecode(jsonMap)) : null) ?? {};
  }

  Future<void> updateApp(String? oldAppName, ServerConfig config, {bool removeNullFields = false}) async {
    if (config.appName?.isNotEmpty ?? false) {
      String prefix = config.appName!;

      if (oldAppName != null) {
        await renameApp(oldAppName, prefix);
      }

      if (config.baseUrl != null) {
        await _sharedPrefs.setString("$prefix.baseUrl", config.baseUrl!.toString());
      } else if (removeNullFields) {
        await _sharedPrefs.remove("$prefix.baseUrl");
      }
      if (config.username != null) {
        await _sharedPrefs.setString("$prefix.username", config.username!);
      } else if (removeNullFields) {
        await _sharedPrefs.remove("$prefix.username");
      }
      if (config.password != null) {
        await _sharedPrefs.setString("$prefix.password", config.password!);
      } else if (removeNullFields) {
        await _sharedPrefs.remove("$prefix.password");
      }
      if (config.title != null) {
        await _sharedPrefs.setString("$prefix.title", config.title!);
      } else if (removeNullFields) {
        await _sharedPrefs.remove("$prefix.title");
      }
      if (config.icon != null) {
        await _sharedPrefs.setString("$prefix.icon", config.icon!);
      } else if (removeNullFields) {
        await _sharedPrefs.remove("$prefix.icon");
      }
      if (config.isDefault != null || removeNullFields) {
        if (config.isDefault ?? false) {
          await updateDefaultApp(config.appName!);
        } else {
          if (await defaultApp() == config.appName) {
            await updateDefaultApp(null);
          }
        }
      }
    }
  }

  Future<void> renameApp(String oldAppName, String? newAppName) async {
    if (newAppName?.isNotEmpty ?? false) {
      String prefix = newAppName!;

      await Future.wait(
        _sharedPrefs.getKeys().where((e) => e.startsWith("$oldAppName.")).map((e) async {
          var value = _sharedPrefs.get(e);
          await _sharedPrefs.remove(e);
          assert(value != null);

          String subKey = e.substring(e.indexOf(".")); // e.g. ".baseUrl"
          String newKey = prefix + subKey;

          if (value is String) {
            await _sharedPrefs.setString(newKey, value);
          } else if (value is bool) {
            await _sharedPrefs.setBool(newKey, value);
          } else if (value is int) {
            await _sharedPrefs.setInt(newKey, value);
          } else if (value is double) {
            await _sharedPrefs.setDouble(newKey, value);
          } else if (value is List<String>) {
            await _sharedPrefs.setStringList(newKey, value);
          } else {
            assert(false, "${value.runtimeType} is not supported by SharedPreferences");
          }
        }).toList(),
      );

      String? currentApp = await appName();
      if (currentApp == oldAppName) {
        await updateAppName(newAppName);
      }

      String? currentDefault = await defaultApp();
      if (currentDefault == oldAppName) {
        await updateDefaultApp(newAppName);
      }
    }
  }

  Future<void> removeApp(String appName) {
    return Future.wait(
      _sharedPrefs.getKeys().where((e) => e.startsWith("$appName.")).map((e) => _sharedPrefs.remove(e)).toList(),
    ).then((_) async {
      if (await defaultApp() == appName) {
        await updateDefaultApp(null);
      }
      if (await lastApp() == appName) {
        await updateLastApp(null);
      }
    });
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Preferences
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Retrieves the [ThemeMode] preference.
  ///
  /// Returns [ThemeMode.system] if none is configured.
  Future<ThemeMode> themePreference() async {
    ThemeMode? themeMode;
    String? theme = _sharedPrefs.getString("theme");
    if (theme != null) {
      themeMode = ThemeMode.values.firstWhereOrNull((e) => e.name == theme);
    }
    return themeMode ?? ThemeMode.system;
  }

  /// Sets the current [ThemeMode] preference.
  ///
  /// If [pThemeMode] is [ThemeMode.system], the preference will be set to `null`.
  Future<void> updateThemePreference(ThemeMode pThemeMode) async {
    if (pThemeMode == ThemeMode.system) {
      await _sharedPrefs.remove("theme");
    } else {
      await _sharedPrefs.setString("theme", pThemeMode.name);
    }
  }

  /// Retrieves the configured max. picture resolution.
  ///
  /// This is being used to limit the resolution of pictures taken via the in-app camera.
  Future<int?> pictureResolution() async {
    return _sharedPrefs.getInt("pictureResolution");
  }

  /// Sets the max. picture resolution.
  Future<void> updatePictureResolution(int pPictureResolution) async {
    await _sharedPrefs.setInt("pictureResolution", pPictureResolution);
  }

  /// Whether the single app mode is active.
  Future<bool> singleAppMode() async {
    return _sharedPrefs.getBool("singleAppMode") ?? false;
  }

  /// Sets the single app mode.
  Future<void> updateSingleAppMode(bool? singleAppMode) {
    if (singleAppMode == null || singleAppMode == false) return _sharedPrefs.remove("singleAppMode");
    return _sharedPrefs.setBool("singleAppMode", singleAppMode);
  }

  /// Retrieves the default app.
  Future<String?> defaultApp() async {
    return _sharedPrefs.getString("defaultApp");
  }

  /// Sets the default app.
  Future<void> updateDefaultApp(String? appName) {
    if (appName == null) return _sharedPrefs.remove("defaultApp");
    return _sharedPrefs.setString("defaultApp", appName);
  }

  /// Retrieves the last opened app.
  Future<String?> lastApp() async {
    return _sharedPrefs.getString("lastApp");
  }

  /// Sets the last opened app.
  Future<void> updateLastApp(String? appName) {
    if (appName == null) return _sharedPrefs.remove("lastApp");
    return _sharedPrefs.setString("lastApp", appName);
  }

  /// Retrieves the last opened app.
  Future<String?> privacyPolicy() async {
    return _sharedPrefs.getString("privacyPolicy");
  }

  /// Sets the last opened app.
  Future<void> updatePrivacyPolicy(String? policy) {
    if (policy == null) return _sharedPrefs.remove("privacyPolicy");
    return _sharedPrefs.setString("privacyPolicy", policy);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Preferences that are saved under the app key
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Retrieves a string value by it's key in connection to the current app name from [SharedPreferences].
  ///
  /// The key is structured as follows:
  /// ```dart
  /// "$appName.$key"
  /// ```
  Future<String?> getString(String key) async {
    String? prefix = await appName();
    if (prefix != null) {
      return getAppString(prefix, key);
    } else {
      return null;
    }
  }

  String? getAppString(String appName, String key) {
    return _sharedPrefs.getString("$appName.$key");
  }

  /// Persists a string value by it's key in connection to the current app name in [SharedPreferences].
  ///
  /// The key is structured as follows:
  /// ```dart
  /// "$appName.$key"
  /// ```
  ///
  /// `null` removes the value from the storage.
  Future<bool> setString(String key, String? value) async {
    String? prefix = await appName();
    assert(prefix != null && prefix.isNotEmpty);

    if (prefix != null) {
      if (value != null) {
        return _sharedPrefs.setString("$prefix.$key", value);
      } else {
        return _sharedPrefs.remove("$prefix.$key");
      }
    }
    return false;
  }

  /// Returns the name of the current app.
  Future<String?> appName() async {
    return _sharedPrefs.getString("appName");
  }

  /// Sets the name of the current app.
  Future<void> updateAppName(String? pAppName) {
    if (pAppName == null) return _sharedPrefs.remove("appName");
    return _sharedPrefs.setString("appName", pAppName);
  }

  /// Returns the saved base url.
  Future<String?> baseUrl() {
    return getString("baseUrl");
  }

  /// Sets the base url for the current app.
  Future<void> updateBaseUrl(String? pBaseUrl) async {
    await setString("baseUrl", pBaseUrl);
  }

  /// Retrieves the saved username.
  Future<String?> username() {
    return getString("username");
  }

  /// Sets the saved username for the current app.
  Future<void> updateUsername(String? pUsername) async {
    await setString("username", pUsername);
  }

  /// Retrieves the saved password.
  Future<String?> password() {
    return getString("password");
  }

  /// Sets the saved password for the current app.
  Future<void> updatePassword(String? pPassword) {
    return setString("password", pPassword);
  }

  /// Retrieves the saved title.
  Future<String?> title() {
    return getString("title");
  }

  /// Sets the title for the current app.
  Future<void> updateTitle(String? title) {
    return setString("title", title);
  }

  /// Retrieves the saved icon.
  Future<String?> icon() {
    return getString("icon");
  }

  /// Sets the icon for the current app.
  Future<void> updateIcon(String? icon) {
    return setString("icon", icon);
  }

  /// Retrieves the saved authKey, which will be used on [ApiStartUpRequest].
  Future<String?> authKey() {
    return getString("authKey");
  }

  /// Sets the authKey.
  Future<void> updateAuthKey(String? pAuthKey) {
    return setString("authKey", pAuthKey);
  }

  /// Retrieves version of the current app.
  Future<String?> version() {
    return getString("version");
  }

  /// Sets the version of the current app.
  Future<void> updateVersion(String? pVersion) async {
    await setString("version", pVersion);
  }

  /// Returns info about the current user.
  Future<UserInfo?> userInfo() async {
    String? jsonMap = await getString("userInfo");
    return jsonMap != null ? UserInfo.fromJson(jsonDecode(jsonMap)) : null;
  }

  /// Sets the current user info.
  Future<void> updateUserInfo(Map<String, dynamic>? pJson) {
    return setString("userInfo", pJson != null ? jsonEncode(pJson) : null);
  }

  /// Returns the user defined language code.
  Future<String?> userLanguage() {
    return getString("language");
  }

  /// Set the user defined language code.
  Future<void> updateUserLanguage(String? pLanguage) async {
    await setString("language", pLanguage);
  }

  /// Returns the application timezone returned by the server.
  Future<String?> applicationTimeZone() {
    return getString("timeZoneCode");
  }

  /// Set the application defined timezone.
  Future<void> updateApplicationTimeZone(String? pTimeZoneCode) async {
    await setString("timeZoneCode", pTimeZoneCode);
  }

  /// Returns the last saved app style.
  Future<Map<String, String>> applicationStyle() async {
    String? jsonMap = await getString("applicationStyle");
    return (jsonMap != null ? Map<String, String>.from(jsonDecode(jsonMap)) : null) ?? {};
  }

  /// Sets the app style.
  Future<void> updateApplicationStyle(Map<String, String>? pAppStyle) async {
    await setString("applicationStyle", pAppStyle != null ? jsonEncode(pAppStyle) : null);
  }

  /// Returns if the app is currently in offline mode.
  Future<bool> offline() async {
    String? prefix = await appName();
    if (prefix != null) {
      return _sharedPrefs.getBool("$prefix.offline") ?? false;
    } else {
      return false;
    }
  }

  /// Sets the offline mode.
  Future<void> updateOffline(bool pOffline) async {
    String? prefix = await appName();
    assert(prefix != null);

    if (prefix != null) {
      await _sharedPrefs.setBool("$prefix.offline", pOffline);
    }
  }

  Future<String?> offlineScreen() async {
    return getString("offlineScreen");
  }

  Future<void> updateOfflineScreen(String pWorkscreen) async {
    await setString("offlineScreen", pWorkscreen);
  }
}
