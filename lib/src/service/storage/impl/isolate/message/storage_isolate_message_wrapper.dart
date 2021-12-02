import 'dart:isolate';

import 'storage_isolate_message.dart';

class StorageIsolateMessageWrapper {

  final StorageIsolateMessage message;
  final SendPort sendPort;


  StorageIsolateMessageWrapper({
    required this.sendPort,
    required this.message
  });

}