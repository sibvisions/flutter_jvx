import 'dart:isolate';

import 'package:flutter_client/src/service/layout/impl/isolate/message/layout_message.dart';

class SetIsValidMessage extends LayoutMessage {
  @override
  sendResponse({required response, required SendPort sendPort}) {
    sendPort.send(response);
  }
}
