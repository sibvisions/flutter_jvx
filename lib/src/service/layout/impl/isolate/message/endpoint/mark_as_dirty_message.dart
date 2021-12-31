import 'dart:isolate';

import 'package:flutter_client/src/service/layout/impl/isolate/message/layout_message.dart';

class MarkAsDirtyMessage extends LayoutMessage<void> {

  final String id;

  MarkAsDirtyMessage({
    required this.id
  });

  @override
  sendResponse({required void response, required SendPort sendPort}) {

  }

}