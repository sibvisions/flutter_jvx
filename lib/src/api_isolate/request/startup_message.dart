import 'dart:isolate';

import 'package:flutter_jvx/src/api_isolate/i_api_isolate_message.dart';

///
/// Perform Startup Request
///
class StartupMessage extends ApiIsolateMessage {

  StartupMessage({
    required SendPort sendPort,
  }) : super(sendPort: sendPort);


  /// Returns new Instance
  StartupMessage.from(StartupMessage message) :
      super.from(message: message);

}