import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../config/app_config.dart';
import '../../flutter_jvx.dart';
import '../mask/menu/menu_mode.dart';

abstract class ConfigUtil {
  /// Tries to read app config
  static Future<AppConfig?> readAppConfig() async {
    try {
      return await _readConfigFile("app.conf.json");
    } catch (e, stack) {
      FlutterJVx.log.e("AppConfig failed to load:", e, stack);
    }
    return null;
  }

  /// Tries to read dev app config
  static Future<AppConfig?> readDevConfig() async {
    try {
      return await _readConfigFile("dev.conf.json");
    } catch (e, stack) {
      if (e is FlutterError && e.message.startsWith("Unable to load asset")) {
        FlutterJVx.log.d("Unable to load asset", e, stack);
        return null;
      }
      FlutterJVx.log.e("Dev AppConfig failed to load:", e, stack);
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
