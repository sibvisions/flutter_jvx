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

abstract class JsonTemplateManager {
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
  JsonTemplateManager._();

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
      FlutterUI.logUI.d("Load json template $templateName");
    }

    if (kIsWeb) {
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
          String jsonTemplate = file!.readAsStringSync();

          jsonTemplate = jsonDecode(jsonTemplate);

          _templateCache[cacheKey] = jsonTemplate;

          if (FlutterUI.logUI.cl(Lvl.d)) {
            FlutterUI.logUI.d("Template $templateName found!");
          }

          return jsonTemplate;
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
          responseType: ResponseType.plain
        )
      );

      dynamic jsonTemplate = await response.data;

      if (jsonTemplate != null) {
        if (FlutterUI.logUI.cl(Lvl.d)) {
          FlutterUI.logUI.d("Template $templateName found!");
        }
      }
      else {
        if (FlutterUI.logUI.cl(Lvl.d)) {
          FlutterUI.logUI.d("Template $templateName was NOT found!");
        }
      }

      jsonTemplate = jsonDecode(jsonTemplate);

      _templateCache[cacheKey] = jsonTemplate;

      return jsonTemplate;
    }
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