import 'dart:convert';

import 'package:flutter/services.dart';

/// Config for Developers:
///
/// Initialize this class and it will automatically get the config file.
///
/// To create a new config add conf.json file to /env/
/// and add the to properties [baseUrl], [appName] and [debug].
/// 
/// [baseUrl]: Url for the JVx Server
/// 
/// [appName]: Application name of the JVx Application
/// 
/// [debug]: 
/// 
///   `true`: The config will load.
/// 
///   `false`: The config will not load.
/// 
/// When releasing or going in production mode. The [debug] property has to be `false`.
class Config {
  String baseUrl;
  String appName;
  bool debug;

  Config({this.baseUrl, this.appName, this.debug});

  Config.fromJson(Map<String, dynamic> json)
    : baseUrl = json['baseUrl'],
      appName = json['appName'],
      debug = json['debug'];

  static Future<Config> loadFile() async {
    String configString =
        await rootBundle.loadString("env/conf.json");

    Config config = Config.fromJson(json.decode(configString));

    return config;
  }
}