import 'dart:isolate';

import '../../../../../../model/command/base_command.dart';
import '../api_isolate_message.dart';

class ApiIsolateSetValueMessage extends ApiIsolateMessage<List<BaseCommand>> {
  /// Id of the session
  final String clientId;

  /// Id of the component
  final String componentId;

  /// value of the component
  final dynamic value;

  ApiIsolateSetValueMessage({required this.value, required this.componentId, required this.clientId});

  @override
  sendResponse({required List<BaseCommand> response, required SendPort sendPort}) {
    sendPort.send(response);
  }
}
