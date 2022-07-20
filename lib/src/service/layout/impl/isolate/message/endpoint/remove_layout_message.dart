import '../../../../../isolate/isolate_message.dart';

class RemoveLayoutMessage extends IsolateMessage<bool> {
  final String componentId;

  RemoveLayoutMessage({required this.componentId});
}
