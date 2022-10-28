import '../../../../../isolate/isolate_message.dart';

class DeleteScreenMessage extends IsolateMessage<bool> {
  final String componentId;

  DeleteScreenMessage({required this.componentId});
}
