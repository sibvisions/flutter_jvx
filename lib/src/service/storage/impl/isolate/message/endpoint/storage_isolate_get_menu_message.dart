import 'dart:isolate';

import 'package:flutter_client/src/model/menu/menu_model.dart';
import 'package:flutter_client/src/service/storage/impl/isolate/message/storage_isolate_message.dart';

class StorageIsolateGetMenuMessage extends StorageIsolateMessage<MenuModel> {


  @override
  sendResponse({required MenuModel response, required SendPort sendPort}) {
    sendPort.send(response);
  }

}