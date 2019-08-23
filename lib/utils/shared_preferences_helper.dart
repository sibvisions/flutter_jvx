import 'dart:convert';

import 'package:jvx_mobile_v3/utils/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  SharedPreferences prefs;
  String appName;
  String baseUrl;
  String language;

  Future<Map<String, String>> getData() async {
    prefs = await SharedPreferences.getInstance();

    Map<String, String> prefData = new Map<String, String>();

    prefData['appName'] = prefs.getString('appName');
    prefData['baseUrl'] = prefs.getString('baseUrl');
    prefData['language'] = prefs.getString('language');

    return prefData;
  }

  Future<Map<String, String>> getLoginData() async {
    prefs = await SharedPreferences.getInstance();
    
    Map<String, String> prefLoginData = new Map<String, String>();

    prefLoginData['authKey'] = prefs.getString('authKey');

    prefLoginData['username'] = prefs.getString('username');
    prefLoginData['password'] = prefs.getString('password');

    return prefLoginData;
  }

  Future<String> getAppVersion() async {
    prefs = await SharedPreferences.getInstance();
    String appVersion = prefs.getString('appVersion');
    return appVersion;
  }

  Future<Map<String, String>> getTranslation() async {
    prefs = await SharedPreferences.getInstance();
    String jsonString = prefs.getString('translation');

    Map<String, String> result;

    if (jsonString != null)
      result = Map.from(json.decode(jsonString).map((key, val) {
        return MapEntry(
          key.toString(),
          val.toString()
        );
      }));
    return result;
  }

  void setData(String appName, String baseUrl, String language) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('appName', appName);
    prefs.setString('baseUrl', baseUrl);
    prefs.setString('language', language);
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
}