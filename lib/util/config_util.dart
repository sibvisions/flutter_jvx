import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../src/model/config/api/url_config.dart';
import '../src/model/config/config_file/app_config.dart';
import 'logging/flutter_logger.dart';

abstract class ConfigUtil {
  ///Tries to read dev app config
  static Future<AppConfig?> readAppConfig() async {
    try {
      String rawConfig = await rootBundle.loadString('assets/config/app.conf.json');
      return AppConfig.fromJson(json: jsonDecode(rawConfig));
    } catch (e) {
      LOGGER.logD(pType: LOG_TYPE.GENERAL, pMessage: "No Dev Config found");
    }
    return null;
  }

  ///Creates a working url config from a given url config
  static UrlConfig createUrlConfig({AppConfig? pAppConfig, UrlConfig? pUrlConfig}) {
    var urlConfig = pUrlConfig ?? UrlConfig.empty();

    if (pAppConfig?.remoteConfig?.devUrlConfigs != null && pAppConfig?.remoteConfig?.indexOfUsingUrlConfig != null) {
      urlConfig = pAppConfig!.remoteConfig!.devUrlConfigs![pAppConfig.remoteConfig!.indexOfUsingUrlConfig];
    }

    //If no https on a remote host, you have to use localhost because of secure cookies
    if (kIsWeb && kDebugMode && urlConfig.host != "localhost" && !urlConfig.https) {
      urlConfig.host = "localhost";
    }
    return urlConfig;
  }
}
