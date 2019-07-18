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

  void setData(String appName, String baseUrl, String language) async {
    prefs = await SharedPreferences.getInstance();

    prefs.setString('appName', appName);
    prefs.setString('baseUrl', baseUrl);
    prefs.setString('language', language);
  }
}