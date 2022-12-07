import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'import_handler_stub.dart'
    if (dart.library.html) 'import_handler_web.dart'
    if (dart.library.io) 'import_handler_mobile.dart' as platform;

FutureOr<void> initTimeZones() {
  return platform.ImportHandler.initializeTimeZones();
}

void fixUrlStrategy() {
  platform.ImportHandler.setHashUrlStrategy();
}

WebSocketChannel createWebSocket(Uri uri, Map<String, dynamic> headers) =>
    platform.ImportHandler.getWebSocketChannel(uri, headers);
