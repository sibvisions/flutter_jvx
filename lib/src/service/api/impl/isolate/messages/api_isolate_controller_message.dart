import 'dart:isolate';

import '../../../shared/i_controller.dart';
import 'api_isolate_message.dart';

class ApiIsolateControllerMessage extends ApiIsolateMessage {
  IController controller;

  ApiIsolateControllerMessage({
    required this.controller,
  });

  @override
  sendResponse({required response, required SendPort sendPort}) {
    // TODO: implement sendResponse
    throw UnimplementedError();
  }
}
