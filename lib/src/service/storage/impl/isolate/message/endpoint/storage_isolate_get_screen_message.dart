import 'dart:isolate';

import '../../../../../../model/component/fl_component_model.dart';
import '../storage_isolate_message.dart';

class StorageIsolateGetScreenMessage extends StorageIsolateMessage<List<FlComponentModel>> {
  final String screenClassName;

  StorageIsolateGetScreenMessage({
    required this.screenClassName
  });

  @override
  sendResponse({required List<FlComponentModel> response, required SendPort sendPort}) {
    sendPort.send(response);
  }
}