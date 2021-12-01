import 'dart:isolate';

import 'package:flutter_client/src/model/menu/menu_model.dart';
import 'package:flutter_client/src/service/storage/impl/isolate/message/storage_isolate_message.dart';

class StorageIsolateSaveMenuMessage extends StorageIsolateMessage<bool> {

  final MenuModel menuModel;


  StorageIsolateSaveMenuMessage({
    required this.menuModel
  });

  @override
  sendResponse({required bool response, required SendPort sendPort}) {
    sendPort.send(response);
  }

}