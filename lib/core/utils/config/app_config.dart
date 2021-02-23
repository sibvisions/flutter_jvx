import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:jvx_flutterclient/core/models/app/app_state.dart';
import 'package:jvx_flutterclient/injection_container.dart';

class AppConfig {
  bool handleSessionTimeout;
  bool rembemerMeChecked;

  AppConfig({this.handleSessionTimeout});

  AppConfig.fromJson(Map<String, dynamic> json)
      : handleSessionTimeout = json['handleSessionTimeout'],
        rembemerMeChecked = json['rembemerMeChecked'];

  static Future<AppConfig> loadFile({String path}) async {
    AppState appState = sl<AppState>();

    AppConfig config;
    try {
      String configString = await rootBundle.loadString(path ?? appState.package
          ? "packages/jvx_flutterclient/env/app.conf.json"
          : "env/app.conf.json");

      config = AppConfig.fromJson(json.decode(configString));
    } catch (e) {
      print('Error: Config File not found');
    }

    return config;
  }
}
