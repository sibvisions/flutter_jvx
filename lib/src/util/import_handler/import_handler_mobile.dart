import 'package:timezone/data/latest.dart' as tz;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Mobile "Implementation" of [ImportHandler]
class ImportHandler {
  static Future<void> initializeTimeZones() async {
    tz.initializeTimeZones();
  }

  static void setHashUrlStrategy() {
    // No-op.
  }

  static WebSocketChannel getWebSocketChannel(Uri uri, Map<String, dynamic> headers) =>
      IOWebSocketChannel.connect(uri, headers: headers);
}
