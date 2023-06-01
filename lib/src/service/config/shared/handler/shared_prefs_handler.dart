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

import '../../../../model/config/user/user_info.dart';
import '../config_handler.dart';

/// Stores all config and session based data.
///
/// Config service is used to store & access all configurable data,
/// also stores session based data such as clientId and userData.
class SharedPrefsHandler implements ConfigHandler {
  final SharedPreferences _sharedPrefs;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SharedPrefsHandler.create({
    required SharedPreferences sharedPrefs,
  }) : _sharedPrefs = sharedPrefs;

  SharedPreferences getSharedPreferences() {
    return _sharedPrefs;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Preferences
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<ThemeMode?> themePreference() async {
    ThemeMode? themeMode;
    String? theme = _sharedPrefs.getString("theme");
    if (theme != null) {
      themeMode = ThemeMode.values.firstWhereOrNull((e) => e.name == theme);
    }
    return themeMode;
  }

  @override
  Future<void> updateThemePreference(ThemeMode? themeMode) {
    if (themeMode == null) return _sharedPrefs.remove("theme");
    return _sharedPrefs.setString("theme", themeMode.name);
  }

  @override
  Future<int?> pictureResolution() async {
    return _sharedPrefs.getInt("pictureResolution");
  }

  @override
  Future<void> updatePictureResolution(int pictureResolution) async {
    await _sharedPrefs.setInt("pictureResolution", pictureResolution);
  }

  @override
  Future<bool> singleAppMode() async {
    return _sharedPrefs.getBool("singleAppMode") ?? false;
  }

  @override
  Future<void> updateSingleAppMode(bool? singleAppMode) {
    if (singleAppMode == null || singleAppMode == false) return _sharedPrefs.remove("singleAppMode");
    return _sharedPrefs.setBool("singleAppMode", singleAppMode);
  }

  @override
  Future<String?> defaultApp() async {
    return _sharedPrefs.getString("defaultApp");
  }

  @override
  Future<void> updateDefaultApp(String? appId) {
    if (appId == null) return _sharedPrefs.remove("defaultApp");
    return _sharedPrefs.setString("defaultApp", appId);
  }

  @override
  Future<String?> lastApp() async {
    return _sharedPrefs.getString("lastApp");
  }

  @override
  Future<void> updateLastApp(String? appId) {
    if (appId == null) return _sharedPrefs.remove("lastApp");
    return _sharedPrefs.setString("lastApp", appId);
  }

  @override
  Future<String?> privacyPolicy() async {
    return _sharedPrefs.getString("privacyPolicy");
  }

  @override
  Future<void> updatePrivacyPolicy(String? policy) {
    if (policy == null) return _sharedPrefs.remove("privacyPolicy");
    return _sharedPrefs.setString("privacyPolicy", policy);
  }

  @override
  Future<T?> getValue<T>(String name) async {
    return _sharedPrefs.get(name) as T?;
  }

  @override
  Future<bool> setValue<T>(String name, T? value) async {
    if (value != null) {
      return _setValue(name, value);
    } else {
      return _sharedPrefs.remove(name);
    }
  }

  Future<bool> _setValue<T>(String newPrefix, T value) async {
    if (value is String) {
      return _sharedPrefs.setString(newPrefix, value);
    } else if (value is bool) {
      return _sharedPrefs.setBool(newPrefix, value);
    } else if (value is int) {
      return _sharedPrefs.setInt(newPrefix, value);
    } else if (value is double) {
      return _sharedPrefs.setDouble(newPrefix, value);
    } else if (value is List<String>) {
      return _sharedPrefs.setStringList(newPrefix, value);
    } else {
      assert(false, "${value.runtimeType} is not supported by SharedPreferences");
      return false;
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Methods used to manage preferences that are saved under the app key
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<Set<String>> getAppKeys() async {
    RegExp regExp = RegExp(r'(.+)\..+');
    return _sharedPrefs
        .getKeys()
        .map((element) => regExp.allMatches(element))
        .where((e) => e.isNotEmpty)
        .map((e) => e.first[1].toString())
        .sorted((a, b) => b.compareTo(a))
        .toSet();
  }

  @override
  Future<void> updateAppKey(String key, String newKey) {
    return Future.wait(
      _sharedPrefs.getKeys().where((e) => e.startsWith("$key.")).map((e) async {
        var value = _sharedPrefs.get(e);
        await _sharedPrefs.remove(e);
        assert(value != null);

        String subKey = e.substring(e.indexOf(".")); // e.g. ".baseUrl"
        String newPrefix = newKey + subKey;

        await _setValue(newPrefix, value);
      }).toList(),
    );
  }

  @override
  Future<void> removeAppKey(String key) {
    return Future.wait(
      _sharedPrefs.getKeys().where((e) => e.startsWith("$key.")).map((e) => _sharedPrefs.remove(e)).toList(),
    );
  }

  /// Retrieves a string value by its key in connection to the current app name.
  ///
  /// {@macro app.key}
  Future<String?> getString(String key) async {
    String? prefix = await currentApp();
    if (prefix != null) {
      return _sharedPrefs.getString("$prefix.$key");
    } else {
      return null;
    }
  }

  /// Persists a string value by its key in connection to the current app name.
  ///
  /// {@macro app.key}
  ///
  /// `null` removes the value from the storage.
  Future<bool> setString(String key, String? value) async {
    String? prefix = await currentApp();
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

  /// Retrieves a bool value by its key in connection to the current app name.
  ///
  /// {@macro app.key}
  Future<bool?> getBool(String key) async {
    String? prefix = await currentApp();
    if (prefix != null) {
      return _sharedPrefs.getBool("$prefix.$key");
    } else {
      return null;
    }
  }

  /// Persists a bool value by its key in connection to the current app name.
  ///
  /// {@macro app.key}
  ///
  /// `null` removes the value from the storage.
  Future<bool> setBool(String key, bool? value) async {
    String? prefix = await currentApp();
    assert(prefix != null && prefix.isNotEmpty);

    if (prefix != null) {
      if (value != null) {
        return _sharedPrefs.setBool("$prefix.$key", value);
      } else {
        return _sharedPrefs.remove("$prefix.$key");
      }
    }
    return false;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Preferences that are saved under the app key
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<String?> currentApp() async {
    return _sharedPrefs.getString("app");
  }

  @override
  Future<void> updateCurrentApp(String? appId) {
    if (appId == null) return _sharedPrefs.remove("app");
    return _sharedPrefs.setString("app", appId);
  }

  @override
  Future<String?> appName() async {
    return getString("name");
  }

  @override
  Future<void> updateAppName(String? appName) {
    return setString("name", appName);
  }

  @override
  Future<String?> baseUrl() {
    return getString("baseUrl");
  }

  @override
  Future<void> updateBaseUrl(String? baseUrl) async {
    await setString("baseUrl", baseUrl);
  }

  @override
  Future<String?> username() {
    return getString("username");
  }

  @override
  Future<void> updateUsername(String? username) async {
    await setString("username", username);
  }

  @override
  Future<String?> password() {
    return getString("password");
  }

  @override
  Future<void> updatePassword(String? password) {
    return setString("password", password);
  }

  @override
  Future<String?> title() {
    return getString("title");
  }

  @override
  Future<void> updateTitle(String? title) {
    return setString("title", title);
  }

  @override
  Future<String?> icon() {
    return getString("icon");
  }

  @override
  Future<void> updateIcon(String? icon) {
    return setString("icon", icon);
  }

  @override
  Future<String?> authKey() {
    return getString("authKey");
  }

  @override
  Future<void> updateAuthKey(String? authKey) {
    return setString("authKey", authKey);
  }

  @override
  Future<String?> version() {
    return getString("version");
  }

  @override
  Future<void> updateVersion(String? version) async {
    await setString("version", version);
  }

  @override
  Future<UserInfo?> userInfo() async {
    String? jsonMap = await getString("userInfo");
    return jsonMap != null ? UserInfo.fromJson(jsonDecode(jsonMap)) : null;
  }

  @override
  Future<void> updateUserInfo(Map<String, dynamic>? json) {
    return setString("userInfo", json != null ? jsonEncode(json) : null);
  }

  @override
  Future<String?> userLanguage() {
    return getString("language");
  }

  @override
  Future<void> updateUserLanguage(String? language) async {
    await setString("language", language);
  }

  @override
  Future<String?> applicationLanguage() {
    return getString("applicationLanguage");
  }

  @override
  Future<void> updateApplicationLanguage(String? language) async {
    await setString("applicationLanguage", language);
  }

  @override
  Future<String?> applicationTimeZone() {
    return getString("timeZoneCode");
  }

  @override
  Future<void> updateApplicationTimeZone(String? timeZoneCode) async {
    await setString("timeZoneCode", timeZoneCode);
  }

  @override
  Future<Map<String, String>?> applicationStyle() async {
    String? jsonMap = await getString("applicationStyle");
    return (jsonMap != null ? Map.from(jsonDecode(jsonMap)) : null);
  }

  @override
  Future<void> updateApplicationStyle(Map<String, String>? appStyle) async {
    await setString("applicationStyle", appStyle != null ? jsonEncode(appStyle) : null);
  }

  @override
  Future<bool> offline() async {
    return (await getBool("offline")) ?? false;
  }

  @override
  Future<void> updateOffline(bool offline) async {
    await setBool("offline", offline);
  }

  @override
  Future<String?> offlineScreen() async {
    return getString("offlineScreen");
  }

  @override
  Future<void> updateOfflineScreen(String workscreen) async {
    await setString("offlineScreen", workscreen);
  }
}
