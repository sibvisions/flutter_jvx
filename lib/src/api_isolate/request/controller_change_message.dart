
import 'dart:isolate';


import 'package:flutter_jvx/src/services/api/i_controller.dart';

import '../i_api_isolate_message.dart';


///
/// Tells the ApiIsolate to use this [IController] and throw away its current one
///
class ControllerChangeMessage extends ApiIsolateMessage {

  ///New Controller
  IController newController;

  ControllerChangeMessage({required this.newController, required SendPort sendPort}) : super(sendPort: sendPort);
}