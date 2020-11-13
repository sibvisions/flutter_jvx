import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jvx_flutterclient/core/models/app/app_state.dart';
import 'package:jvx_flutterclient/injection_container.dart';

class Config {
  String baseUrl;
  String appName;
  bool debug;
  String username;
  String password;
  String appMode = 'full';
  Widget startupWidget;

  Config(
      {this.baseUrl,
      this.appName,
      this.debug,
      this.username,
      this.password,
      this.appMode,
      this.startupWidget});

  Config.fromJson(Map<String, dynamic> json)
      : baseUrl = json['baseUrl'],
        appName = json['appName'],
        debug = json['debug'],
        username = json['username'],
        password = json['password'],
        appMode = json['appMode'];

  static Future<Config> loadFile({String path, Config conf}) async {
    AppState appState = sl<AppState>();

    if (conf != null) {
      return conf;
    }
    Config config;

    if (!kReleaseMode) {
      try {
        String configString = await rootBundle.loadString(
            path ?? appState.package
                ? "packages/jvx_flutterclient/env/conf.json"
                : "env/conf.json",
            cache: false);

        config = Config.fromJson(json.decode(configString));
      } catch (e) {
        print('Warning: Config file not found!');
      }
    }

    return config;
  }
}
