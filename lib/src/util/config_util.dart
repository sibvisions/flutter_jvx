/* Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

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
