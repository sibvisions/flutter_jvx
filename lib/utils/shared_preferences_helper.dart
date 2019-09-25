import 'dart:convert';
import 'dart:core';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  SharedPreferences prefs;
  String appName;
  String baseUrl;
  String language;

  Future<bool> getWelcome() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('welcome') == null)
      return true;
    return false;
  }

  Future<Map<String, String>> getData() async {
    prefs = await SharedPreferences.getInstance();

    Map<String, String> prefData = <String, String>{};

    prefData['appName'] = prefs.getString('appName');
    prefData['baseUrl'] = prefs.getString('baseUrl');
    prefData['language'] = prefs.getString('language');

    return prefData;
  }

  Future<Map<String, String>> getLoginData() async {
    prefs = await SharedPreferences.getInstance();
    
    Map<String, String> prefLoginData = <String, String>{};

    prefLoginData['authKey'] = prefs.getString('authKey');

    prefLoginData['username'] = prefs.getString('username');
    prefLoginData['password'] = prefs.getString('password');

    return prefLoginData;
  }

  Future<String> getAppVersion() async {
    prefs = await SharedPreferences.getInstance();
    String appVersion = prefs.getString('appVersion');
    if (appVersion != null)
      return appVersion;
    
    return "0.0.0";
  }

  Future<Map<String, String>> getTranslation() async {
    prefs = await SharedPreferences.getInstance();
    String jsonString = prefs.getString('translation');

    Map<String, String> result = <String, String>{};

    if (jsonString != null)
      result = Map.from(json.decode(jsonString).map((key, val) {
        return MapEntry(
          key.toString(),
          val.toString()
        );
      }));
    return result;
  }

  Future<Map<String, dynamic>> getApplicationStyle() async {
    prefs = await SharedPreferences.getInstance();
    String jsonString = prefs.getString('applicationStyle');

    Map<String, dynamic> result;

    if (jsonString != null)
      result = Map.from(json.decode(jsonString).map((key, val) {
        if (key.toString() == 'menu')
          return MapEntry(
            key.toString(),
            Map.from(val.map((k, v) {
              return MapEntry(
                k.toString(),
                v.toString()
              );
            }))
          );

        return MapEntry(
          key.toString(),
          val.toString()
        );
      }));
    else
      return null;

    // return result;
    return null;
  }

  void setWelcome(bool welcome) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setBool('welcome', welcome);
  }

  void setData(String appName, String baseUrl, String language) async {
    prefs = await SharedPreferences.getInstance();
    if (appName != null && appName.isNotEmpty) prefs.setString('appName', appName);
    if (baseUrl != null && baseUrl.isNotEmpty) prefs.setString('baseUrl', baseUrl);
    if (language != null && language.isNotEmpty) prefs.setString('language', language);
  }

  void setLoginData(String username, String password) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('username', username);
    prefs.setString('password', password);
  }

  void setAuthKey(String authKey) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('authKey', authKey);
  }

  void setAppVersion(String appVersion) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('appVersion', appVersion);
  }

  void setTranslation(Map<String, String> translation) async {
    String hashmapString = json.encode(translation);

    prefs = await SharedPreferences.getInstance();

    prefs.setString('translation', hashmapString);
  }

  void setApplicationStyle(Map<String, dynamic> applicationStyle) async {
    String hashmapString = json.encode(applicationStyle);

    prefs = await SharedPreferences.getInstance();

    prefs.setString('applicationStyle', hashmapString);
  }
}