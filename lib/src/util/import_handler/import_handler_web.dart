import 'dart:async';

import 'package:flutter_web_plugins/flutter_web_plugins.dart' as web_plugins;
import 'package:timezone/browser.dart' as tz;
import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Web "Implementation" of [ImportHandler]
class ImportHandler {
  static FutureOr<void> initializeTimeZones() {
    return tz.initializeTimeZone();
  }

  static void setHashUrlStrategy() {
    web_plugins.setUrlStrategy(const FixedHashUrlStrategy());
  }

  static WebSocketChannel getWebSocketChannel(Uri uri, Map<String, dynamic> headers) =>
      HtmlWebSocketChannel.connect(uri);
}

class FixedHashUrlStrategy extends web_plugins.HashUrlStrategy {
  final web_plugins.PlatformLocation _platformLocation;

  const FixedHashUrlStrategy([this._platformLocation = const web_plugins.BrowserPlatformLocation()])
      : super(_platformLocation);

  @override
  String prepareExternalUrl(String internalUrl) {
    // Workaround for https://github.com/flutter/flutter/issues/116415
    return "${_platformLocation.pathname}${_platformLocation.search}${internalUrl.isEmpty ? '' : '#$internalUrl'}";
  }
}
