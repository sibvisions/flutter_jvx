import 'dart:convert';

import 'package:flutter/services.dart';

class AppConfig {
  bool handleSessionTimeout;

  AppConfig({this.handleSessionTimeout});

  AppConfig.fromJson(Map<String, dynamic> json)
    : handleSessionTimeout = json['handleSessionTimeout'];

  static Future<AppConfig> loadFile() async {
    AppConfig config;
    try {
      String configString =
          await rootBundle.loadString("packages/jvx_mobile_v3/env/app.conf.json");

      config = AppConfig.fromJson(json.decode(configString));
    } catch (e) {
      print('Error: Config File not found');
    }

    return config;
  }
}