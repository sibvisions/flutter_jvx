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

  /// for webview http code debug only
  // ignore: unused_field
  Timer? _patchTimer;

  @override
  void dispose() {
    //_patchTimer?.cancel();

    super.dispose();
  }

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
        await controller.addJavaScriptChannel("FlutterLog",
          onMessageReceived: (message) {
            log(message.message);
        });
        await controller.setNavigationDelegate(NavigationDelegate(
/*
            onProgress: (progress) {
                // Bei 50%, 70%, 90% und 100% schießen wir das Skript rein
                if (progress > 50) {
                    _startPatchTimer(controller);
                }
            },
            onPageFinished: (url) async {
                _startPatchTimer(controller);
            },
 */
          onWebResourceError: (WebResourceError error) async {
            log("Authentication - webviewHttpError: ${error.errorCode} ${error.errorType} ${error.description}", error: error);

            var cookies = await cookieManager.getCookies(location);

            log("Authentication - cookies: ${cookies.toString()}");
          },
          onNavigationRequest: (request) async {
            final url = request.url;

            if (url.startsWith("weblink://azauth")) {
              Uri? uri = Uri.tryParse(url);

              if (uri != null) {
                log("Query parameters: ${uri.queryParameters}");

                if (uri.queryParameters["error"] == null
                    || uri.queryParameters["error_subcode"] == null) {
                  log("Authentication - redirect to: $url");

                  var cookies = await cookieManager.getCookies(location);

                  log("Authentication - cookies: ${cookies.toString()}");

                  //don't await here -> await would block and without we'll see the splash animation
                  authResponse = resendRequest(headers: {"Referer": url, "X-MOBILE_AUTH": "ok"});

                  _webAuth = true;

                  unawaited(WebViewDialogService.hide());
                }
                else {
                  //e.g. error_subcode=cancel
                  //     error=access_denied
                  if (IUiService().canRouteToAppOverview()) {
                    unawaited(IUiService().routeToAppOverview());

                    unawaited(WebViewDialogService.hide());
                  }
                }
              }

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

  /*
  void _startPatchTimer(WebViewController controller) {
    _patchTimer?.cancel();

    _patchTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _patchWebsite(controller);
    });

    //stop timer after 20 seconds
    Future.delayed(Duration(seconds: 20), () => _patchTimer?.cancel());
  }

  void _patchWebsite(WebViewController controller) {
    const replacements = {
      'old': 'new',
      'old2': 'new2',
      'old3': 'new3',
    };

    final String jsonReplacements = jsonEncode(replacements);

    controller.runJavaScript('''
    (function() {
      var replacements = $jsonReplacements;
      var keys = Object.keys(replacements);
      
      function walk(node) {
        var child = node.firstChild;
        while (child) {
          if (child.nodeType === 3) {
            var value = child.nodeValue;
            var changed = false;
            
            for (var i = 0; i < keys.length; i++) {
              var oldN = keys[i];
              if (value.includes(oldN)) {
                value = value.replace(new RegExp(oldN, 'g'), replacements[oldN]);
                changed = true;
              }
            }
            
            if (changed) {
              child.nodeValue = value;
            }
          } else if (child.nodeType === 1) {
            if (child.tagName !== 'SCRIPT' && child.tagName !== 'STYLE') {
              walk(child);
            }
          }
          child = child.nextSibling;
        }
      }

      if (document.body) {
        walk(document.body);
      }
    })();
    '''
    );
  }
*/

}
