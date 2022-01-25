import 'dart:isolate';

import '../layout_message.dart';

class SetIsValidMessage extends LayoutMessage {
  @override
  sendResponse({required response, required SendPort sendPort}) {
    sendPort.send(response);
  }
}
