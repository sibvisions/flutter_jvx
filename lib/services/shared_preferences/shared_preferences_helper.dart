import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  SharedPreferences prefs;

  Future<String> getAppName() async {
    prefs = await SharedPreferences.getInstance();
    String appName = prefs.getString('appName');
    return appName;
  }

  Future<String> getBaseUrl() async {
    prefs = await SharedPreferences.getInstance();
    String baseUrl = prefs.getString('baseUrl');
    return baseUrl;
  }

  void setAppName(String appName) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('appName', appName);
  }

  void setBaseUrl(String baseUrl) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('baseUrl', baseUrl);
  }
}