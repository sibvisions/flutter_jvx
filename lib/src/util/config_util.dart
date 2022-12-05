import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../config/app_config.dart';
import '../flutter_ui.dart';
import '../mask/menu/menu.dart';

abstract class ConfigUtil {
  /// Tries to read app config
  static Future<AppConfig?> readAppConfig() async {
    try {
      return await _readConfigFile("app.conf.json");
    } catch (e, stack) {
      FlutterUI.log.e("AppConfig failed to load:", e, stack);
    }
    return null;
  }

  /// Tries to read dev app config
  static Future<AppConfig?> readDevConfig() async {
    try {
      return await _readConfigFile("dev.conf.json");
    } catch (e, stack) {
      if (e is FlutterError && e.message.startsWith("Unable to load asset")) {
        FlutterUI.log.d("Unable to load asset", e, stack);
        return null;
      }
      FlutterUI.log.e("Dev AppConfig failed to load:", e, stack);
    }
    return null;
  }

  /// Read file config
  static Future<AppConfig?> _readConfigFile(String name) {
    return rootBundle
        .loadString("assets/config/$name")
        .then((rawAppConfig) => AppConfig.fromJson(jsonDecode(rawAppConfig)));
  }

  static MenuMode getMenuMode(String? menuModeString) {
    MenuMode menuMode;
    switch (menuModeString) {
      case "list":
        menuMode = MenuMode.LIST;
        break;
      case "list_grouped":
        menuMode = MenuMode.LIST_GROUPED;
        break;
      case "drawer":
        menuMode = MenuMode.DRAWER;
        break;
      case "swiper":
        menuMode = MenuMode.SWIPER;
        break;
      case "tabs":
        menuMode = MenuMode.TABS;
        break;
      case "grid":
        menuMode = MenuMode.GRID;
        break;
      case "grid_grouped":
      default:
        menuMode = MenuMode.GRID_GROUPED;
    }
    return menuMode;
  }
}
