import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsState {
  SharedPreferences prefs;

  SharedPrefsState() {
    init();
  }

  init() async => prefs = await SharedPreferences.getInstance();

  set appName(String appName) => prefs.setString('appName', appName);

  set baseUrl(String baseUrl) => prefs.setString('baseUrl', baseUrl);

  set language(String language) => prefs.setString('language', language);

  String get appName => prefs.getString('appName');

  String get baseUrl => prefs.getString('baseUrl');

  String get language => prefs.getString('language');
}