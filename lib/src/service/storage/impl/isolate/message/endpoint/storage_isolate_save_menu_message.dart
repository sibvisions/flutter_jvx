import 'dart:isolate';

import '../../../../../../model/menu/menu_model.dart';
import '../storage_isolate_message.dart';

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