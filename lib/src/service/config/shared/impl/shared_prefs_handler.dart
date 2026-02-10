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
import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../../flutter_ui.dart';
import '../../../../model/config/user/user_info.dart';
import '../config_handler.dart';

/// Stores all config and session based data.
///
/// Config service is used to store & access all configurable data,
/// also stores session based data such as clientId and userData.
class SharedPrefsHandler implements ConfigHandler {
  final SharedPreferences _sharedPrefs;

  final FlutterSecureStorage _securePrefs;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SharedPrefsHandler._(
    this._sharedPrefs,
    this._securePrefs);

  static Future<SharedPrefsHandler> create() async {
    final prefs = await SharedPreferences.getInstance();
    final secure = FlutterSecureStorage();

    SharedPrefsHandler handler = SharedPrefsHandler._(prefs, secure);

    return handler;
  }

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
  Future<String?> getValueSecure(String name) async {
    if (kIsWeb) {
      return _securePrefs.read(key: name).then((value) {
        return decrypt(value, name);
      });
    }
    else {
      return _securePrefs.read(key: name);
    }
  }

  @override
  Future<bool> setValue<T>(String name, T? value) async {
    if (value == null) {
      return _sharedPrefs.remove(name);
    }
    else if (value is String) {
      return _sharedPrefs.setString(name, value);
    } else if (value is bool) {
      return _sharedPrefs.setBool(name, value);
    } else if (value is int) {
      return _sharedPrefs.setInt(name, value);
    } else if (value is double) {
      return _sharedPrefs.setDouble(name, value);
    } else if (value is List<String>) {
      return _sharedPrefs.setStringList(name, value);
    } else {
      assert(false, "${value.runtimeType} is not supported by SharedPreferences");
      return false;
    }
  }

  @override
  Future<bool> setValueSecure<T>(String name, String? value) async {
    if (value != null) {
      var unsecure = await getValue(name);

      //if an unsecure value was available for same name -> remove it
      if (unsecure != null) {
        unawaited(setValue(name, null));
      }

      String encValue;

      if (kIsWeb) {
        encValue = await encrypt(value, name);
      }
      else {
        encValue = value;
      }

      await _securePrefs.write(key: name, value: encValue);

      var current = await _securePrefs.read(key: name);

      return current == encValue;
    } else {
      await _securePrefs.delete(key: name);
      var current = await _securePrefs.read(key: name);

      return current == null;
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
  Future<void> updateWhere(bool Function(String key) test, String newKey) {
    return Future.wait(
      _sharedPrefs.getKeys().where(test).map((e) async {
        var value = _sharedPrefs.get(e);
        await _sharedPrefs.remove(e);
        assert(value != null);

        String subKey = e.substring(e.indexOf(".")); // e.g. ".baseUrl"
        String newPrefix = newKey + subKey;

        await setValue(newPrefix, value);
      }).toList(),
    );
  }

  @override
  Future<void> updateAppKey(String key, String newKey) {
    return updateWhere((e) => e.startsWith("$key."), newKey);
  }

  @override
  Future<void> removeWhere(bool Function(String key) test) {
    return Future.wait(
      _sharedPrefs.getKeys().where(test).map((e) => _sharedPrefs.remove(e)).toList(),
    );
  }

  @override
  Future<void> removeAppKeys(String key, {bool Function(String subKey)? filter}) {
    return removeWhere((e) => e.startsWith("$key.") && (filter == null || filter(e)));
  }

  /// Retrieves a string value by its key in connection to the current app name.
  ///
  /// {@macro app.key}
  Future<String?> _getString(String key, [bool secure = false]) async {
    String? prefix = await currentApp();
    if (prefix != null) {
      if (secure) {
       return getValueSecure("$prefix.$key");
      }
      else {
        return getValue("$prefix.$key");
      }
    } else {
      return null;
    }
  }

  /// Persists a string value by its key in connection to the current app name.
  ///
  /// {@macro app.key}
  ///
  /// `null` removes the value from the storage.
  Future<bool> _setString(String key, String? value, [bool secure = false]) async {
    String? prefix = await currentApp();
    assert(prefix != null && prefix.isNotEmpty, "Can't set $key=$value without a prefix!");

    if (prefix != null) {
      if (secure) {
        return setValueSecure("$prefix.$key", value);
      }
      else {
        return setValue("$prefix.$key", value);
      }
    }
    return false;
  }

  /// Retrieves a bool value by its key in connection to the current app name.
  ///
  /// {@macro app.key}
  Future<bool?> _getBool(String key) async {
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
  Future<bool> _setBool(String key, bool? value) async {
    String? prefix = await currentApp();
    assert(prefix != null && prefix.isNotEmpty, "Can't set $key=$value without a prefix!");

    if (prefix != null) {
      if (value != null) {
        return _sharedPrefs.setBool("$prefix.$key", value);
      } else {
        return _sharedPrefs.remove("$prefix.$key");
      }
    }
    return false;
  }

  /// Derives a key from a key code (maybe an appId)
  Future<SecretKey> deriveKey(String keyCode) async {
    String packName = FlutterUI.packageInfo.packageName;

    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 50000,
      bits: 256,
    );

    return pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(keyCode)),
      nonce: utf8.encode(packName),
    );
  }

  /// Encrypts a [text] with [keyCode]
  Future<String> encrypt(String text, String keyCode) async {
    final algorithm = AesGcm.with256bits();
    final key = await deriveKey(keyCode);

    final secretBox = await algorithm.encrypt(
      utf8.encode(text),
      secretKey: key,
    );

    final map = {
      'nonce': base64Encode(secretBox.nonce),
      'cipher': base64Encode(secretBox.cipherText),
      'mac': base64Encode(secretBox.mac.bytes),
    };

    return jsonEncode(map);
  }

  /// Decrypts an [encrypted] text with [keyCode]
  Future<String?> decrypt(String? encrypted, String keyCode) async {
    if (encrypted == null) {
      return null;
    }

    final algorithm = AesGcm.with256bits();
    final key = await deriveKey(keyCode);

    final map = jsonDecode(encrypted);

    final secretBox = SecretBox(
      base64Decode(map['cipher']),
      nonce: base64Decode(map['nonce']),
      mac: Mac(base64Decode(map['mac'])),
    );

    final decrypted = await algorithm.decrypt(
      secretBox,
      secretKey: key,
    );

    return utf8.decode(decrypted);
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
    return _getString("name");
  }

  @override
  Future<void> updateAppName(String? appName) {
    return _setString("name", appName);
  }

  @override
  Future<String?> baseUrl() {
    return _getString("baseUrl");
  }

  @override
  Future<void> updateBaseUrl(String? baseUrl) async {
    await _setString("baseUrl", baseUrl);
  }

  @override
  Future<String?> username() {
    return _getString("username", true);
  }

  @override
  Future<void> updateUsername(String? username) async {
    await _setString("username", username, true);
  }

  @override
  Future<String?> password() {
    return _getString("password", true);
  }

  @override
  Future<void> updatePassword(String? password) {
    return _setString("password", password, true);
  }

  @override
  Future<String?> title() {
    return _getString("title");
  }

  @override
  Future<void> updateTitle(String? title) {
    return _setString("title", title);
  }

  @override
  Future<String?> icon() {
    return _getString("icon");
  }

  @override
  Future<void> updateIcon(String? icon) {
    return _setString("icon", icon);
  }

  @override
  Future<String?> authKey() {
    return _getString("authKey", true);
  }

  @override
  Future<void> updateAuthKey(String? authKey) {
    return _setString("authKey", authKey, true);
  }

  @override
  Future<String?> version() {
    return _getString("version");
  }

  @override
  Future<void> updateVersion(String? version) async {
    await _setString("version", version);
  }

  @override
  Future<UserInfo?> userInfo() async {
    String? jsonMap = await _getString("userInfo");
    return jsonMap != null ? UserInfo.fromJson(jsonDecode(jsonMap)) : null;
  }

  @override
  Future<void> updateUserInfo(Map<String, dynamic>? json) {
    return _setString("userInfo", json != null ? jsonEncode(json) : null);
  }

  @override
  Future<bool?> customLanguage() {
    return _getBool("customLanguage");
  }

  @override
  Future<void> updateCustomLanguage(bool? customLanguage) async {
    await _setBool("customLanguage", customLanguage);
  }

  @override
  Future<String?> userLanguage() {
    return _getString("language");
  }

  @override
  Future<void> updateUserLanguage(String? language) async {
    await _setString("language", language);
  }

  @override
  Future<String?> applicationLanguage() {
    return _getString("applicationLanguage");
  }

  @override
  Future<void> updateApplicationLanguage(String? language) async {
    await _setString("applicationLanguage", language);
  }

  @override
  Future<String?> applicationTimeZone() {
    return _getString("timeZoneCode");
  }

  @override
  Future<void> updateApplicationTimeZone(String? timeZoneCode) async {
    await _setString("timeZoneCode", timeZoneCode);
  }

  @override
  Future<Map<String, String>?> applicationStyle() async {
    String? jsonMap = await _getString("applicationStyle");
    return (jsonMap != null ? Map.from(jsonDecode(jsonMap)) : null);
  }

  @override
  Future<void> updateApplicationStyle(Map<String, String>? appStyle) async {
    await _setString("applicationStyle", appStyle != null ? jsonEncode(appStyle) : null);
  }

  @override
  Future<bool> offline() async {
    return (await _getBool("offline")) ?? false;
  }

  @override
  Future<void> updateOffline(bool offline) async {
    await _setBool("offline", offline);
  }

  @override
  Future<String?> offlineScreen() async {
    return _getString("offlineScreen");
  }

  @override
  Future<void> updateOfflineScreen(String workScreen) async {
    await _setString("offlineScreen", workScreen);
  }

  @override
  Future<String> installId() async {
    String? installId = await _getString("installId");

    if (installId == null) {
      installId = const Uuid().v4();

      //get global id
      String? globalInstallId = await getValue("installId");

      if (globalInstallId == null) {
        globalInstallId = const Uuid().v4();

        await (setValue("installId", globalInstallId));
      }

      //don't wait
      unawaited(_setString("installId", "$globalInstallId#$installId"));
    }

    return installId;
  }

  @override
  Future<void> clear() async {
    await _sharedPrefs.clear();
  }
}
