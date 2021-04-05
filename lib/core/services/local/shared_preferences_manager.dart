import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:jvx_flutterclient/core/models/api/response/menu_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  final SharedPreferences sharedPreferences;
  final _iv = IV.fromLength(16);
  final encrypter =
      Encrypter(AES(Key.fromUtf8('dkAO8lt3BPf6MrI3f9qnwIL1SW8kH5Va')));

  SharedPreferencesManager(this.sharedPreferences);

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

    String username = this.sharedPreferences.getString('username');
    String password = this.sharedPreferences.getString('password');

    if (username != null && username.isNotEmpty)
      data.putIfAbsent(
          'username',
          () => encrypter.decrypt(
              Encrypted.fromBase64(
                  this.sharedPreferences.getString('username')),
              iv: _iv));
    if (password != null && password.isNotEmpty)
      data.putIfAbsent(
          'password',
          () => encrypter.decrypt(
              Encrypted.fromBase64(
                  this.sharedPreferences.getString('password')),
              iv: _iv));

    return data;
  }

  Map<String, dynamic> get syncLoginData {
    Map<String, dynamic> data = <String, dynamic>{};

    data.putIfAbsent(
        'username',
        () => encrypter.decrypt(
            Encrypted.fromBase64(
                this.sharedPreferences.getString('syncUsername')),
            iv: _iv));
    data.putIfAbsent(
        'password',
        () => encrypter.decrypt(
            Encrypted.fromBase64(
                this.sharedPreferences.getString('syncPassword')),
            iv: _iv));

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

  bool get warmWelcome => sharedPreferences.getBool('warmWelcome') ?? true;

  set warmWelcome(bool warmWelcome) =>
      sharedPreferences.setBool('warmWelcome', warmWelcome);

  void setAppData(
      {String appName,
      String baseUrl,
      String language,
      int picSize,
      bool overrideOnNull = false}) async {
    if (appName != null && appName.isNotEmpty)
      await this.sharedPreferences.setString('appName', appName);
    if (baseUrl != null && baseUrl.isNotEmpty)
      await this.sharedPreferences.setString('baseUrl', baseUrl);
    if ((language != null && language.isNotEmpty) || overrideOnNull)
      await this.sharedPreferences.setString('language', language);
    if (picSize != null &&
        (picSize == 320 || picSize == 640 || picSize == 1024))
      await this.sharedPreferences.setInt('picSize', picSize);
  }

  void setLoginData(
      {String username, String password, bool override = false}) async {
    if ((username != null && username.isNotEmpty) || override) {
      if (username != null && username.isNotEmpty)
        await this
            .sharedPreferences
            .setString('username', encrypter.encrypt(username, iv: _iv).base64);
      else if (this.sharedPreferences.containsKey('username'))
        await this.sharedPreferences.remove('username');
    }
    if ((password != null && password.isNotEmpty) || override) {
      if (password != null && password.isNotEmpty)
        await this
            .sharedPreferences
            .setString('password', encrypter.encrypt(password, iv: _iv).base64);
      else if (this.sharedPreferences.containsKey('password'))
        await this.sharedPreferences.remove('password');
    }
  }

  void setSyncLoginData(
      {String username, String password, bool override = false}) async {
    if ((username != null && username.isNotEmpty) || override) {
      await this.sharedPreferences.setString(
          'syncUsername', encrypter.encrypt(username, iv: _iv).base64);
    } else {
      await this.sharedPreferences.remove('syncUsername');
    }
    if ((password != null && password.isNotEmpty) || override) {
      await this.sharedPreferences.setString(
          'syncPassword', encrypter.encrypt(password, iv: _iv).base64);
    } else {
      await this.sharedPreferences.remove('syncPassword');
    }
  }

  void setOfflineLoginHash({String username, String password}) async {
    if (username != null &&
        username.isNotEmpty &&
        password != null &&
        password.isNotEmpty) {
      String usernameHash = sha256.convert(utf8.encode(username)).toString();
      String passwordHash = sha256.convert(utf8.encode(password)).toString();

      await this.sharedPreferences.setString('usernameHash', usernameHash);
      await this.sharedPreferences.setString('passwordHash', passwordHash);
    } else {
      await this.sharedPreferences.remove('usernameHash');
      await this.sharedPreferences.remove('passwordHash');
    }
  }

  void setAppVersion(String appVersion) async =>
      await this.sharedPreferences.setString('appVersion', appVersion);

  void setPreviousAppVersion(String previousAppVersion) async => await this
      .sharedPreferences
      .setString('prevAppVersion', previousAppVersion);

  void setApplicationStylingHash(String applicationStylingHash) async =>
      await this
          .sharedPreferences
          .setString('applicationStylingHash', applicationStylingHash);

  void setTranslation(Map<String, dynamic> translation) async {
    String jsonString = json.encode(translation);

    await this.sharedPreferences.setString('translation', jsonString);
  }

  void setApplicationStyle(Map<String, dynamic> applicationStyle) async {
    String jsonString = json.encode(applicationStyle);

    await this.sharedPreferences.setString('applicationStyle', jsonString);
  }

  void setDeviceId(String deviceId) async =>
      await this.sharedPreferences.setString('deviceId', deviceId);

  void setDownloadFileName(String fileName) async =>
      await this.sharedPreferences.setString('fileName', fileName);

  void setMobileOnly(bool mobileOnly) async =>
      await this.sharedPreferences.setBool('mobileOnly', mobileOnly);

  void setAuthKey(String authKey) async {
    if (authKey != null && authKey.isNotEmpty)
      await this.sharedPreferences.setString('authKey', authKey);
    else if (this.sharedPreferences.containsKey('authKey'))
      await this.sharedPreferences.remove('authKey');
  }

  void setOffline(bool offline) async =>
      await this.sharedPreferences.setBool('offline', offline);

  void setMenuItems(List<MenuItem> menuItems) async {
    try {
      if (menuItems != null)
        await this
            .sharedPreferences
            .setString('menuItems', json.encode(menuItems));
    } catch (e) {
      print('Couldn\'t encode menu items');
    }
  }

  bool login(String username, String password) {
    String usernameHash = sha256.convert(utf8.encode(username)).toString();
    String passwordHash = sha256.convert(utf8.encode(password)).toString();

    String savedUsernameHash = this.sharedPreferences.getString('usernameHash');
    String savedPasswordHash = this.sharedPreferences.getString('passwordHash');

    if (usernameHash == savedUsernameHash &&
        passwordHash == savedPasswordHash) {
      return true;
    }
    return false;
  }
}
