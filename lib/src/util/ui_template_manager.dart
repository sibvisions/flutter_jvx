/*
 * Copyright 2025 SIB Visions GmbH
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
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api/api_route.dart';
import '../flutter_ui.dart';
import '../service/api/i_api_service.dart';
import '../service/config/i_config_service.dart';
import '../service/file/file_manager.dart';
import 'jvx_logger.dart';

abstract class UITemplateManager {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The template cache
  static final Map<String, dynamic> _templateCache = {};

  /// The http client
  static final Dio _client = Dio();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // Private constructor to prevent instantiation
  UITemplateManager._();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Gets whether the cache already contains the template for [templateName]
  static bool hasTemplate(String? templateName) {
    return _templateCache.containsKey("${IConfigService().currentApp.value!}:$templateName");
  }

  /// Gets the cached template by [templateName]
  static dynamic getTemplateFromCache(String? templateName) {
    return _templateCache["${IConfigService().currentApp.value!}:$templateName"];
  }

  /// Gets the template for the given [templateName]
  static Future<dynamic> loadTemplate(String templateName) async {
    IConfigService servConf = IConfigService();

    String appName = servConf.currentApp.value!;

    String cacheKey = "$appName:$templateName";

    if (_templateCache.containsKey(cacheKey)) {
      return _templateCache[cacheKey];
    }

    String url = templateName;

    if (url.startsWith("/")) {
      url = url.substring(1);
    }

    if (FlutterUI.logUI.cl(Lvl.d)) {
      FlutterUI.logUI.d("Load UI template $templateName");
    }

    if (!kIsWeb) {
      String? appVersion = servConf.version.value;

      if (appVersion != null) {
        IFileManager fileManager = servConf.getFileManager();

        String path = fileManager.getAppSpecificPath(
          "${IFileManager.TEMPLATES_PATH}/$url",
          appId: appName,
          version: appVersion,
        );

        File? file = fileManager.getFileSync(path);

        if (file?.existsSync() == true) {
          dynamic tplBytes = await file!.readAsBytes();

          if (FlutterUI.logUI.cl(Lvl.d)) {
            FlutterUI.logUI.d("Template $templateName found!");
          }

          if (isBinaryRfw(tplBytes)) {
            _templateCache[cacheKey] = tplBytes;

            return tplBytes;
          }
          else {
            String uiTemplate = utf8.decode(tplBytes);

            uiTemplate = decodeTemplate(uiTemplate);

            _templateCache[cacheKey] = uiTemplate;

            return uiTemplate;
          }
        }
        else {
          //no template available
          _templateCache[cacheKey] = null;

          if (FlutterUI.logUI.cl(Lvl.d)) {
            FlutterUI.logUI.d("Template $templateName was NOT found!");
          }

          return null;
        }
      }

      return null;
    } else {
      Uri baseUrl = servConf.baseUrl.value!;
      String appName = servConf.appName.value!;

      Response response = await _client.request(
        "$baseUrl/resource/$appName/$url",
        options: Options(
          method: Method.GET.name,
          headers: _getHeaders(),
          responseType: ResponseType.bytes
        )
      );

      dynamic uiTemplate = await response.data;

      if (uiTemplate != null) {
        if (FlutterUI.logUI.cl(Lvl.d)) {
          FlutterUI.logUI.d("Template $templateName found!");
        }
      }
      else {
        if (FlutterUI.logUI.cl(Lvl.d)) {
          FlutterUI.logUI.d("Template $templateName was NOT found!");
        }
      }

      if (isBinaryRfw(uiTemplate)) {
        _templateCache[cacheKey] = uiTemplate;
      }
      else {
        if (uiTemplate is Uint8List) {
          uiTemplate = utf8.decode(uiTemplate);
        }

        uiTemplate = decodeTemplate(uiTemplate);

        _templateCache[cacheKey] = uiTemplate;
      }

      return uiTemplate;
    }
  }

  static bool isBinaryRfw(dynamic data) {
    if (data is Uint8List) {
      if (data.length < 4) return false;

      // "arfw" (0x61, 0x72, 0x66, 0x77)
      bool isArfw = data[0] == 0x61 && data[1] == 0x72 &&
                    data[2] == 0x66 && data[3] == 0x77;

      // (0xFE, 'R', 'F', 'W')
      bool isFeRfw = data[0] == 0xFE && data[1] == 0x52 &&
                     data[2] == 0x46 && data[3] == 0x57;

      // (0xFE, 'R', 'F', 'W')
      bool isRfw0 = data[0] == 0x52 && data[1] == 0x46 &&
                    data[2] == 0x57 && data[3] == 0;


      return isArfw || isFeRfw || isRfw0;
    }

    return false;
  }

  static dynamic decodeTemplate(dynamic uiTemplate) {
    if (uiTemplate != null) {
      if (uiTemplate is String) {
        //problems with parsing
        String template = uiTemplate.replaceAll('\r\n', '\n');

        if (template.trimLeft().startsWith("{") && template.trimRight().endsWith("}")) {
          return jsonDecode(template);
        }

        return template;
      }
    }

    return uiTemplate;
  }

  static Map<String, String> _getHeaders() {
    IApiService servApi = IApiService();

    Map<String, String> headers = servApi.getRepository().getHeaders();

    if (!kIsWeb) {
      Set<Cookie> cookies = servApi.getRepository().getCookies();
      if (cookies.isNotEmpty) {
        String cookieNew = cookies.map((e) => "${e.name}=${e.value}").join("; ");

        String? cookieOld = headers[HttpHeaders.cookieHeader];
        if (cookieOld != null) {
          headers[HttpHeaders.cookieHeader] = "$cookieOld; $cookieNew}";
        }
        else {
          headers[HttpHeaders.cookieHeader] = cookieNew;
        }
      }
    }

    return headers;
  }

  /// Clears the template cache
  static void clearCache() {
    _templateCache.clear();
  }

}