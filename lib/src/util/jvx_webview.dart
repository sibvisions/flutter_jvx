import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../flutter_ui.dart';

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
              error,
            );
          },
        ),
      )
      ..loadRequest(widget.initialUrl);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _controller.canGoBack()) {
          await _controller.goBack();
          return false;
        }
        return widget.dismissible;
      },
      child: WebViewWidget(controller: _controller),
    );
  }
}
