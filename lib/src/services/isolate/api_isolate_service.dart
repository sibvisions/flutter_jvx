import 'dart:developer';
import 'dart:isolate';

import 'package:flutter_jvx/src/api_isolate/request/startup_message.dart';


class ApiIsolateService {

  ///The Api Isolate reference
  final Isolate apiIsolate;

  ///Port to send messages to the isolate
  final SendPort sendPort;

  ///Port where the answer will be received
  final ReceivePort receivePort = ReceivePort();

  ApiIsolateService({required this.sendPort, required this.apiIsolate}){
    receivePort.listen((message) {receivedAnswer(message);});
  }


  receivedAnswer(dynamic response) {
    log("WOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOORKS");
    log(response.toString());
  }


  startUp() {
    sendPort.send(
        StartupMessage(sendPort: receivePort.sendPort)
    );
  }
}


