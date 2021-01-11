import 'dart:convert';

import 'package:jvx_flutterclient/core/models/api/response/menu_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  final SharedPreferences sharedPreferences;

  SharedPreferencesManager(this.sharedPreferences);

  bool get warmWelcome {
    bool result = this.sharedPreferences.getBool('warmWelcome');

    if (result != null && !result) {
      return false;
    } else {
      this.sharedPreferences.setBool('warmWelcome', false);
      return true;
    }
  }

  String get authKey => this.sharedPreferences.getString('authKey');

  String get appVersion =>
      this.sharedPreferences.getString('appVersion') ?? '0.0.0';

  String get previousAppVersion =>
      this.sharedPreferences.getString('prevAppVersion') ?? '';

  String get applicationStylingHash =>
      this.sharedPreferences.getString('applicationStylingHash') ?? '';

  String get deviceId => this.sharedPreferences.getString('deviceId');

  String get downloadFileName =>
      this.sharedPreferences.getString('fileName') ?? '';

  bool get mobileOnly => this.sharedPreferences.getBool('mobileOnly');

  Map<String, dynamic> get appData {
    Map<String, dynamic> data = <String, dynamic>{};

    data.putIfAbsent(
        'appName', () => this.sharedPreferences.getString('appName'));
    data.putIfAbsent(
        'baseUrl', () => this.sharedPreferences.getString('baseUrl'));
    data.putIfAbsent(
        'language', () => this.sharedPreferences.getString('language'));
    data.putIfAbsent('picSize', () => this.sharedPreferences.getInt('picSize'));

    return data;
  }

  Map<String, dynamic> get loginData {
    Map<String, dynamic> data = <String, dynamic>{};

    data.putIfAbsent(
        'username', () => this.sharedPreferences.getString('username'));
    data.putIfAbsent(
        'password', () => this.sharedPreferences.getString('password'));

    return data;
  }

  Map<String, dynamic> get applicationStyle {
    String jsonString = this.sharedPreferences.getString('applicationStyle');

    if (jsonString != null)
      return json.decode(jsonString);
    else
      return null;
  }

  Map<String, dynamic> get translation {
    String jsonString = this.sharedPreferences.getString('translation');

    if (jsonString != null)
      return json.decode(jsonString);
    else
      return null;
  }

  bool get isOffline => this.sharedPreferences.getBool('offline');

  List<MenuItem> get menuItems {
    try {
      List<MenuItem> items =
          (json.decode(this.sharedPreferences.getString('menuItems'))
                  as List<dynamic>)
              .map<MenuItem>((e) => MenuItem.fromJson(e))
              .toList();

      return items;
    } catch (e) {
      print('Couldn\'t parse MenuItems');
      return null;
    }
  }

  void setAppData(
      {String appName,
      String baseUrl,
      String language,
      int picSize,
      bool overrideOnNull = false}) {
    if (appName != null && appName.isNotEmpty)
      this.sharedPreferences.setString('appName', appName);
    if (baseUrl != null && baseUrl.isNotEmpty)
      this.sharedPreferences.setString('baseUrl', baseUrl);
    if ((language != null && language.isNotEmpty) || overrideOnNull)
      this.sharedPreferences.setString('language', language);
    if (picSize != null &&
        (picSize == 320 || picSize == 640 || picSize == 1024))
      this.sharedPreferences.setInt('picSize', picSize);
  }

  void setLoginData({String username, String password, bool override = false}) {
    if ((username != null && username.isNotEmpty) || override) {
      this.sharedPreferences.setString('username', username);
    }
    if ((password != null && password.isNotEmpty) || override) {
      this.sharedPreferences.setString('password', password);
    }
  }

  void setAppVersion(String appVersion) =>
      this.sharedPreferences.setString('appVersion', appVersion);

  void setPreviousAppVersion(String previousAppVersion) =>
      this.sharedPreferences.setString('prevAppVersion', previousAppVersion);

  void setApplicationStylingHash(String applicationStylingHash) => this
      .sharedPreferences
      .setString('applicationStylingHash', applicationStylingHash);

  void setTranslation(Map<String, dynamic> translation) {
    String jsonString = json.encode(translation);

    this.sharedPreferences.setString('translation', jsonString);
  }

  void setApplicationStyle(Map<String, String> applicationStyle) {
    String jsonString = json.encode(applicationStyle);

    this.sharedPreferences.setString('applicationStyle', jsonString);
  }

  void setDeviceId(String deviceId) =>
      this.sharedPreferences.setString('deviceId', deviceId);

  void setDownloadFileName(String fileName) =>
      this.sharedPreferences.setString('fileName', fileName);

  void setMobileOnly(bool mobileOnly) =>
      this.sharedPreferences.setBool('mobileOnly', mobileOnly);

  void setAuthKey(String authKey) =>
      this.sharedPreferences.setString('authKey', authKey);

  void setOffline(bool offline) =>
      this.sharedPreferences.setBool('offline', offline);

  void setMenuItems(List<MenuItem> menuItems) {
    try {
      if (menuItems != null)
        this.sharedPreferences.setString('menuItems', json.encode(menuItems));
    } catch (e) {
      print('Couldn\'t encode menu items');
    }
  }
}
