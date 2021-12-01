import 'dart:isolate';

import 'api_isolate_message.dart';

class ApiIsolateMessageWrapper {
  final ApiIsolateMessage message;
  final SendPort sendPort;

  ApiIsolateMessageWrapper({
    required this.sendPort,
    required this.message
  });
}