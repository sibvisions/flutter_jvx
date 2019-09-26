import 'dart:convert';

import 'package:flutter/services.dart';

/// Config for Developers
///
/// Initialize this class and it will automatically get the config file
///
/// To create a new config add conf.json file to /env/
/// and add the to properties [baseUrl] and [appName]
class Config {
  String baseUrl;
  String appName;

  Config({this.baseUrl, this.appName});

  Config.fromJson(Map<String, dynamic> json)
    : baseUrl = json['baseUrl'],
      appName = json['appName'];

  static Future<Config> loadFile() async {
    String configString =
        await rootBundle.loadString("env/conf.json");

    Config config = Config.fromJson(json.decode(configString));

    return config;
  }
}