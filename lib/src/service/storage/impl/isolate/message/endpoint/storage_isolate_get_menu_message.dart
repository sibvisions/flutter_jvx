import 'dart:isolate';

import '../../../../../../model/menu/menu_model.dart';
import '../storage_isolate_message.dart';

class StorageIsolateGetMenuMessage extends StorageIsolateMessage<MenuModel> {


  @override
  sendResponse({required MenuModel response, required SendPort sendPort}) {
    sendPort.send(response);
  }

}