import 'dart:isolate';

import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/api/impl/isolate/messages/api_isolate_message.dart';

class ApiIsolateOpenScreenMessage extends ApiIsolateMessage<List<BaseCommand>> {

  final String clientId;
  final String componentId;


  ApiIsolateOpenScreenMessage({
    required this.clientId,
    required this.componentId
  });

  @override
  sendResponse({required List<BaseCommand> response, required SendPort sendPort}) {
    sendPort.send(response);
  }

}