import 'dart:convert';

import 'package:flutter/services.dart';

import '../../models/api/errors/failure.dart';

class DevConfig {
  final String baseUrl;
  final String appName;
  final String appMode;
  final String? username;
  final String? password;
  final Map<String, dynamic>? properties;

  DevConfig(
      {required this.baseUrl,
      required this.appName,
      required this.appMode,
      this.username,
      this.password,
      this.properties});

  DevConfig.fromJson(
      {required Map<String, dynamic> map,
      required Map<String, dynamic> properties})
      : baseUrl = map['baseUrl'],
        appName = map['appName'],
        appMode = map['appMode'],
        username = map['username'],
        password = map['password'],
        properties = properties;

  static Future<DevConfig> loadConfig(
      {required String path, bool package = false}) async {
    try {
      if (path.trim().isNotEmpty) {
        final String configString = await rootBundle.loadString(
            package ? 'packages/flutterclient/$path' : path,
            cache: false);

        final Map<String, dynamic> map = json.decode(configString);

        final DevConfig devConfig =
            DevConfig.fromJson(map: map, properties: map);

        return devConfig;
      }
    } catch (e) {
      throw CacheFailure(
          message: e.toString(),
          title: 'Load Config error',
          name: 'message.error',
          details: '');
    }

    throw CacheFailure(
        message: 'Could not load dev config!',
        title: 'Load Config error',
        name: 'message.error',
        details: '');
  }
}
