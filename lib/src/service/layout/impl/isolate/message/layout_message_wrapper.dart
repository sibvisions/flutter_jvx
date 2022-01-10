import 'dart:isolate';

import 'layout_message.dart';

class LayoutMessageWrapper {

  final LayoutMessage message;
  final SendPort sendPort;


  LayoutMessageWrapper({
    required this.sendPort,
    required this.message
  });

}