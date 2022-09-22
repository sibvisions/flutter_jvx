import 'package:web_socket_channel/web_socket_channel.dart';

import 'web_socket_stub.dart'
    if (dart.library.io) 'mobile_web_socket.dart'
    if (dart.library.html) 'browser_web_socket.dart' as platform;

abstract class UniversalWebSocketChannel {
  /// factory constructor to return the correct implementation.
  static WebSocketChannel create(Uri uri, Map<String, dynamic> headers) => platform.getWebSocketChannel(uri, headers);
}
