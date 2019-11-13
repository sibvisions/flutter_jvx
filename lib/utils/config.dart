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
  String username;
  String password;
  String appMode;

  Config({this.baseUrl, this.appName, this.debug, this.username, this.password, this.appMode});

  Config.fromJson(Map<String, dynamic> json)
    : baseUrl = json['baseUrl'],
      appName = json['appName'],
      debug = json['debug'],
      username = json['username'],
      password = json['password'],
      appMode = json['appMode'];

  static Future<Config> loadFile() async {
    Config config;
    try {
      String configString =
          await rootBundle.loadString("env/conf.json");

      config = Config.fromJson(json.decode(configString));
    } catch (e) {
      print('Error: Config File not found');
    }

    return config;
  }
}