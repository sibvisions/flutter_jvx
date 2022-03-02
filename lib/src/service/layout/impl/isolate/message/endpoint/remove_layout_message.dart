import 'dart:isolate';

import '../layout_message.dart';

class RemoveLayoutMessage extends LayoutMessage<bool> {
  final String componentId;

  RemoveLayoutMessage({required this.componentId});

  @override
  sendResponse({required bool response, required SendPort sendPort}) {
    sendPort.send(response);
  }
}
