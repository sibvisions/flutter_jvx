import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

WebSocketChannel getWebSocketChannel(Uri uri, Map<String, dynamic> headers) =>
    IOWebSocketChannel.connect(uri, headers: headers);
