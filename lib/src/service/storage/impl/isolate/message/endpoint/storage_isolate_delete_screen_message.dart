import 'dart:isolate';

import '../storage_isolate_message.dart';

class StorageIsolateDeleteScreenMessage extends StorageIsolateMessage<bool> {
  final String screenName;

  StorageIsolateDeleteScreenMessage({required this.screenName});

  @override
  sendResponse({required void response, required SendPort sendPort}) {
    sendPort.send(null);
  }
}
