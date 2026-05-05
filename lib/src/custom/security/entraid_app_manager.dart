/*
 * Copyright 2026 SIB Visions GmbH
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

import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:webview_cookie_manager_plus/webview_cookie_manager_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../model/api_interaction.dart';
import '../../model/request/api_request.dart';
import '../../model/response/api_response.dart';
import '../../model/response/show_document_response.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/widgets/web/webview_dialog_service.dart';
import '../app_manager.dart';

class EntraIDAppManager extends AppManager {

  /// whether authentication was web based
  bool _webAuth = false;

  @override
  Future<void> onInitStartup() async {
    _webAuth = false;
  }

  @override
  void modifyResponses(ApiInteraction interaction) {
    if (_webAuth && "/api/logout" == interaction.request?.requestPath) {
      for (int i = 0; i < interaction.responses.length; i++) {
        if (interaction.responses[i] is ShowDocumentResponse) {
          ApiResponse resp = interaction.responses[i];
          interaction.responses.clear();
          interaction.responses.add(resp);

          return;
        }
      }
    }
  }

  @override
  Future<Response> handleResponse(ApiRequest request, Response originalResponse, ResendRequestFunction resendRequest) async {
    Future<Response>? authResponse;

    if (request.requestBaseUrl != null) {
      String? location = originalResponse.headers.value("Location");

      if (originalResponse.statusCode == 302 && location != null && location.contains("login.microsoftonline.com") == true) {
        // access to cookies
        final cookieManager = WebviewCookieManager();

        WebViewController controller = WebViewController();
        await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
        await controller.setNavigationDelegate(NavigationDelegate(
          onWebResourceError: (WebResourceError error) async {
            log("Authentication - webviewHttpError: ${error.errorCode} ${error.errorType} ${error.description}", error: error);

            var cookies = await cookieManager.getCookies(location);

            log("Authentication - cookies: ${cookies.toString()}");
          },
          onNavigationRequest: (request) async {
            final url = request.url;

            if (url.startsWith("weblink://azauth")) {
              log("Authentication - redirect to: $url");

              var cookies = await cookieManager.getCookies(location);

              log("Authentication - cookies: ${cookies.toString()}");

              //don't await here -> await would block and without we'll see the splash animation
              authResponse = resendRequest(headers: {"Referer": url, "X-MOBILE_AUTH": "ok"});

              _webAuth = true;

              unawaited(WebViewDialogService.hide());

              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          }
        ));

        unawaited(controller.loadRequest(Uri.parse(location)));

        await WebViewDialogService.show(title: "Authentication", controller: controller);
      }
    }

    if (authResponse != null) {
      return authResponse!;
    }

    return originalResponse;
  }

  @override
  bool showDocument(ApiRequest? request, String url) {
    Uri? uri = Uri.tryParse(url);

    if (_webAuth && uri != null) {
      if (uri.path.endsWith("logoutnow") && uri.queryParameters["url"] != null) {
        Uri uriLogout = Uri.parse(uri.queryParameters["url"]!);

        if (uriLogout.host == "login.microsoftonline.com") {
          WebViewController controller = WebViewController();
          controller.setJavaScriptMode(JavaScriptMode.unrestricted)
              .then((value) =>
              controller.setNavigationDelegate(NavigationDelegate(
                onWebResourceError: (WebResourceError error) async {
                  log("WebViewDialog error: ${error.errorCode} ${error.errorType} ${error.description}", error: error);
                },
                onPageFinished: (url) {
                  if (_webAuth && IUiService().canRouteToAppOverview()) {
                    IUiService().routeToAppOverview();
                  }

                  _webAuth = false;
                },
                onNavigationRequest: (request) {
                  if (request.url.startsWith("weblink://azauth?applogout")) {
                    if (_webAuth && IUiService().canRouteToAppOverview()) {
                      IUiService().routeToAppOverview();
                    }

                    _webAuth = false;

                    return NavigationDecision.prevent;
                  }
                  return NavigationDecision.navigate;
                },
              ))).then((value) {
            controller.loadRequest(uriLogout);

            WebViewDialogService.show(
                title: "Authentication",
                dismissible: true,
                controller: controller
            );
          });

          return true;
        }
        else {
          _webAuth = false;
        }
      }
      else {
        _webAuth = false;
      }
    }

    return false;
  }
}
