import 'dart:isolate';

import 'package:flutter_client/src/service/storage/impl/isolate/message/storage_isolate_message.dart';

class StorageIsolateMessageWrapper {

  final StorageIsolateMessage message;
  final SendPort sendPort;


  StorageIsolateMessageWrapper({
    required this.sendPort,
    required this.message
  });

}