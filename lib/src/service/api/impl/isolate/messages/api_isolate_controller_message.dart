import '../../../../isolate/isolate_message.dart';
import '../../../shared/i_controller.dart';

class ApiIsolateControllerMessage extends IsolateMessage {
  IController controller;

  ApiIsolateControllerMessage({
    required this.controller,
  });
}
