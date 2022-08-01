import 'dart:convert';

import 'package:flutter/services.dart';

import '../../data/config/app_config.dart';
import '../../util/logging/flutter_logger.dart';
import '../service/config/i_config_service.dart';

abstract class ConfigUtil {
  /// Tries to read app config
  static Future<AppConfig?> readAppConfig() async {
    try {
      return await _readConfigFile("app.conf.json");
    } catch (e, stackTrace) {
      LOGGER.logD(
          pType: LOG_TYPE.CONFIG, pMessage: "App Config File failed to load: " + e.toString(), pStacktrace: stackTrace);
    }
    return null;
  }

  /// Tries to read dev app config
  static Future<AppConfig?> readDevConfig() async {
    try {
      return await _readConfigFile("dev.conf.json");
    } catch (e, stackTrace) {
      LOGGER.logD(
          pType: LOG_TYPE.CONFIG,
          pMessage: "Dev App Config File failed to load: " + e.toString(),
          pStacktrace: stackTrace);
    }
    return null;
  }

  /// Read file config
  static Future<AppConfig?> _readConfigFile(String name) {
    return rootBundle
        .loadString('assets/config/$name')
        .then((rawAppConfig) => AppConfig.fromJson(json: jsonDecode(rawAppConfig)));
  }

  static MenuMode getMenuMode(String? menuModeString) {
    MenuMode menuMode;
    switch (menuModeString) {
      case 'grid':
        menuMode = MenuMode.GRID;
        break;
      case 'list':
        menuMode = MenuMode.LIST;
        break;
      case 'tabs':
        menuMode = MenuMode.TABS;
        break;
      case 'grid_grouped':
      default:
        menuMode = MenuMode.GRID_GROUPED;
    }
    return menuMode;
  }
}
