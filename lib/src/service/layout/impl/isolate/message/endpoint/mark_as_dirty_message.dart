import '../../../../../isolate/isolate_message.dart';

class MarkAsDirtyMessage extends IsolateMessage {
  final String id;

  MarkAsDirtyMessage({required this.id});
}
