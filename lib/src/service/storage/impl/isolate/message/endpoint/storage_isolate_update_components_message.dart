import 'dart:isolate';

import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/component/fl_component_model.dart';
import 'package:flutter_client/src/service/storage/impl/isolate/message/storage_isolate_message.dart';

class StorageIsolateUpdateComponentsMessage extends StorageIsolateMessage<List<BaseCommand>>{
  final List<dynamic>? componentsToUpdate;
  final List<FlComponentModel>? newComponents;

  StorageIsolateUpdateComponentsMessage({
    required this.componentsToUpdate,
    required this.newComponents
  });

  @override
  sendResponse({required List<BaseCommand> response, required SendPort sendPort}) {
    sendPort.send(response);
  }

}