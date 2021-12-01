import 'dart:isolate';

import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/api/impl/isolate/messages/api_isolate_message.dart';

class ApiIsolateLoginMessage extends ApiIsolateMessage<List<BaseCommand>>{

  final String userName;
  final String password;
  final String clientId;

  ApiIsolateLoginMessage({
    required this.userName,
    required this.password,
    required this.clientId
  });

  @override
  sendResponse({required List<BaseCommand> response, required SendPort sendPort}) {
    sendPort.send(response);
  }

}