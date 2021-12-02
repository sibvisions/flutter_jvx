import 'dart:isolate';

import '../../../../../../model/command/base_command.dart';
import '../api_isolate_message.dart';

class ApiIsolateDeviceStatusMessage extends ApiIsolateMessage<List<BaseCommand>>{

  final double screenWidth;
  final double screenHeight;
  final String clientId;

  ApiIsolateDeviceStatusMessage({
    required this.screenHeight,
    required this.screenWidth,
    required this.clientId
  });

  @override
  sendResponse({required List<BaseCommand> response, required SendPort sendPort}) {
    sendPort.send(response);
  }

}