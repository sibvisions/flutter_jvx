import 'dart:isolate';

import 'isolate_message.dart';

class IsolateMessageWrapper<T extends IsolateMessage> {
  final T message;
  final SendPort sendPort;

  IsolateMessageWrapper({required this.sendPort, required this.message});
}
