import 'dart:isolate';

import '../layout_message.dart';

class LayoutInProcessMessage extends LayoutMessage<bool> {
  @override
  sendResponse({required response, required SendPort sendPort}) {
    sendPort.send(response);
  }
}
