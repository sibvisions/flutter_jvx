import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/layout/impl/isolate/message/layout_message.dart';

class SetScreenSizeMessage extends LayoutMessage<List<BaseCommand>>{

  final String componentId;

  final Size size;


  SetScreenSizeMessage({
    required this.size,
    required this.componentId
  });

  @override
  sendResponse({required List<BaseCommand> response, required SendPort sendPort}) {
    sendPort.send(response);
  }


}