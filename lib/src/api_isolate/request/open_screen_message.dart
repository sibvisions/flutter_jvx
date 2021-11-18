import 'dart:isolate';

import 'package:flutter_jvx/src/api_isolate/i_api_isolate_message.dart';

class OpenScreenMessage extends ApiIsolateMessage{

  final String componentId;

  OpenScreenMessage({
    required this.componentId,
    required SendPort sendPort,
  }) : super(sendPort: sendPort);

  OpenScreenMessage.from(OpenScreenMessage openScreenMessage) :
      componentId = openScreenMessage.componentId,
      super.from(message: openScreenMessage);
}