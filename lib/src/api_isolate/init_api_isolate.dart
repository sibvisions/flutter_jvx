import 'dart:isolate';

import 'package:flutter_jvx/src/api_isolate/handler/message_handler.dart';

void initApiIsolate(SendPort callerSendPort) {

  //Initial Handshake
  ReceivePort messageReceiver = ReceivePort();
  callerSendPort.send(messageReceiver.sendPort);



  MessageHandler messageHandler = MessageHandler();
  messageReceiver.listen(messageHandler.receivedMessage);
}