/*
 * Copyright 2023 SIB Visions GmbH
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

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../flutter_ui.dart';

class JVxWebView extends StatefulWidget {
  final Uri initialUrl;
  final bool dismissible;

  const JVxWebView({
    super.key,
    required this.initialUrl,
    this.dismissible = true,
  });

  @override
  JVxWebViewState createState() => JVxWebViewState();
}

class JVxWebViewState extends State<JVxWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (WebResourceError error) {
            FlutterUI.logAPI.w(
              "WebView ResourceError: ${error.errorCode} ${error.errorType} ${error.description}",
              error: error,
            );
          },
        ),
      )
      ..loadRequest(widget.initialUrl);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        //before await, to avoid problem and warning
        NavigatorState navigator = Navigator.of(context);

        if (await _controller.canGoBack()) {
          await _controller.goBack();
        }
        else if (widget.dismissible) {
          navigator.pop();
        }
      },
      child: WebViewWidget(controller: _controller),
    );
  }
}
