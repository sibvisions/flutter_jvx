import 'dart:isolate';

import '../layout_message.dart';

class LayoutValidMessage extends LayoutMessage<bool> {
  bool set;

  bool value;

  LayoutValidMessage({required this.set, required this.value});

  @override
  sendResponse({required bool response, required SendPort sendPort}) {
    sendPort.send(response);
  }
}
