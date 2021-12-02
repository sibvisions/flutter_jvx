import 'dart:isolate';

import '../../../../../../model/command/base_command.dart';

import '../api_isolate_message.dart';

class ApiIsolateStartUpMessage extends ApiIsolateMessage<List<BaseCommand>> {
  final String appName;

  ApiIsolateStartUpMessage({
    required this.appName,
  });

  @override
  sendResponse({required List<BaseCommand> response, required SendPort sendPort}) {
    sendPort.send(response);
  }


}