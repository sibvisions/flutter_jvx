import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import '../../models/api/errors/failure.dart';
import 'package:yaml/yaml.dart';

import 'server_config.dart';

class AppConfig {
  final bool package;
  final bool rememberMeChecked;
  final bool hideLoginCheckbox;
  final bool handleSessionTimeout;
  final bool loginColorsInverted;
  final int requestTimeout;
  final ServerConfig? initialConfig;
  final Map<String, dynamic>? startupParameter;

  AppConfig(
      {required this.package,
      required this.rememberMeChecked,
      required this.hideLoginCheckbox,
      required this.handleSessionTimeout,
      required this.loginColorsInverted,
      required this.requestTimeout,
      this.initialConfig,
      this.startupParameter});

  AppConfig.fromJson({required Map<String, dynamic> map})
      : package = map['package'],
        rememberMeChecked = map['rememberMeChecked'],
        hideLoginCheckbox = map['hideLoginCheckbox'],
        handleSessionTimeout = map['handleSessionTimeout'],
        loginColorsInverted = map['loginColorsInverted'],
        requestTimeout = map['requestTimeout'],
        initialConfig = ServerConfig.fromJson(map: map['initialConfig']),
        startupParameter = map['startupParameter'];

  AppConfig.fromYaml({required YamlMap map})
      : package = map['package'],
        rememberMeChecked = map['rememberMeChecked'],
        hideLoginCheckbox = map['hideLoginCheckbox'],
        handleSessionTimeout = map['handleSessionTimeout'],
        loginColorsInverted = map['loginColorsInverted'],
        requestTimeout = map['requestTimeout'],
        initialConfig = map['initialConfig'] != null
            ? ServerConfig.fromYaml(map: map['initialConfig'])
            : null,
        startupParameter = map['startupParameter'].cast<String, dynamic>();

  static Future<Either<Failure, AppConfig>> loadConfig(
      {required String path, bool package = false}) async {
    try {
      if (path.contains('.yaml')) {
        if (path.trim().isNotEmpty) {
          final String configString = await rootBundle
              .loadString(package ? 'packages/flutterclient/$path' : path);

          final YamlMap map = loadYaml(configString);

          final AppConfig appConfig = AppConfig.fromYaml(map: map);

          return Right(appConfig);
        }
      } else {
        final String configString = await rootBundle
            .loadString(package ? 'packages/flutterclient/$path' : path);

        final Map<String, dynamic> map = json.decode(configString);

        final AppConfig appConfig = AppConfig.fromJson(map: map);

        return Right(appConfig);
      }
    } catch (e) {
      return Left(CacheFailure(
          title: 'Load config error',
          details: '',
          name: 'message.error',
          message: e.toString()));
    }

    return Left(CacheFailure(
        message: 'Could not load dev config!',
        title: 'Load Config error',
        name: 'message.error',
        details: ''));
  }
}
