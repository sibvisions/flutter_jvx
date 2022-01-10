import 'dart:isolate';

import 'package:flutter_client/src/service/layout/impl/isolate/message/layout_message.dart';

class MarkAsDirtyMessage extends LayoutMessage<bool> {

  final String id;

  MarkAsDirtyMessage({
    required this.id
  });

  @override
  sendResponse({required bool response, required SendPort sendPort}) {
    sendPort.send(response);
  }

}