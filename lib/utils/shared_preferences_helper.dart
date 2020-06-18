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

  Future<Map<String, dynamic>> getData() async {
    prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> prefData = <String, dynamic>{};

    prefData['appName'] = prefs.getString('appName');
    prefData['baseUrl'] = prefs.getString('baseUrl');
    prefData['language'] = prefs.getString('language');
    prefData['picSize'] = prefs.getInt('picSize');

    return prefData;
  }

  Future<Map<String, String>> getLoginData() async {
    prefs = await SharedPreferences.getInstance();
    
    Map<String, String> prefLoginData = <String, String>{};

    prefLoginData['authKey'] = prefs.getString('authKey');

    if (prefs.getString('username') != null)
      prefLoginData['username'] = prefs.getString('username');
    else
      prefLoginData['username'] = '';
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

  Future<String> getPrevAppVersion() async {
    prefs = await SharedPreferences.getInstance();
    String appVersion = prefs.getString('prevAppVersion');
    if (appVersion != null)
      return appVersion;
    
    return "";
  }

  Future<String> getApplicationStylingHash() async {
    prefs = await SharedPreferences.getInstance();
    String applicationStylingHash = prefs.getString('applicationStylingHash');
    if (applicationStylingHash != null)
      return applicationStylingHash;
    
    return "";
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

  Future<String> getDeviceId() async {
    prefs = await SharedPreferences.getInstance();
    return prefs.getString('deviceId');
  }

  Future<String> getDownloadFileName() async {
    prefs = await SharedPreferences.getInstance();
    return prefs.getString('fileName');
  }

  void setWelcome(bool welcome) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setBool('welcome', welcome);
  }

  void setData(String appName, String baseUrl, String language, int picSize) async {
    prefs = await SharedPreferences.getInstance();
    if (appName != null && appName.isNotEmpty) prefs.setString('appName', appName);
    if (baseUrl != null && baseUrl.isNotEmpty) {
      prefs.setString('baseUrl', baseUrl);
    }
    if (language != null && language.isNotEmpty) prefs.setString('language', language);
    if (picSize != null && (picSize == 320 || picSize == 640 || picSize == 1024)) prefs.setInt('picSize', picSize);
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

  void setPrevAppVersion(String appVersion) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('prevAppVersion', appVersion);
  }

  void setApplicationStylingHash(String applicationStylingHash) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('applicationStylingHash', applicationStylingHash);
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

  void setDeviceId(String deviceId) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('deviceId', deviceId);
  }

  void setDownloadFileName(String fileName) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('fileName', fileName);
  }
  
}