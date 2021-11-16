import 'dart:isolate';

import 'package:flutter_jvx/src/api_isolate/i_api_isolate_message.dart';

class AppNameChangeMessage extends ApiIsolateMessage {
  final String appName;

  AppNameChangeMessage({
    required SendPort sendPort,
    required this.appName
  }) : super(sendPort: sendPort);
}