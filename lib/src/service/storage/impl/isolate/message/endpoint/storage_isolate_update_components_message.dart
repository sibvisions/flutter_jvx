import 'dart:isolate';

import '../../../../../../model/command/base_command.dart';
import '../../../../../../model/component/fl_component_model.dart';
import '../storage_isolate_message.dart';

class StorageIsolateUpdateComponentsMessage extends StorageIsolateMessage<List<BaseCommand>>{
  final List<dynamic>? componentsToUpdate;
  final List<FlComponentModel>? newComponents;
  final String screenClassName;

  StorageIsolateUpdateComponentsMessage({
    required this.componentsToUpdate,
    required this.newComponents,
    required this.screenClassName
  });

  @override
  sendResponse({required List<BaseCommand> response, required SendPort sendPort}) {
    sendPort.send(response);
  }

}