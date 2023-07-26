/*
 * Copyright 2022 SIB Visions GmbH
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

abstract class ConfigUtil {
  /// Tries to read app config
  static Future<AppConfig?> readAppConfig() async {
    try {
      // Await here to trigger catch block
      return await _readConfigFile("app.conf.json");
    } catch (e, stack) {
      FlutterUI.log.e("AppConfig failed to load:", error: e, stackTrace: stack);
    }
    return null;
  }

  /// Tries to read dev app config
  static Future<AppConfig?> readDevConfig() async {
    try {
      // Await here to trigger catch block
      return await _readConfigFile("dev.conf.json");
    } catch (e, stack) {
      if (e is FlutterError && e.message.startsWith("Unable to load asset")) {
        FlutterUI.log.d("Unable to load asset", error: e, stackTrace: stack);
        return null;
      }
      FlutterUI.log.e("Dev AppConfig failed to load:", error: e, stackTrace: stack);
    }
    return null;
  }

  /// Read file config
  static Future<AppConfig?> _readConfigFile(String name) {
    return rootBundle
        .loadString("assets/config/$name")
        .then((rawAppConfig) => AppConfig.fromJson(jsonDecode(rawAppConfig)));
  }
}
