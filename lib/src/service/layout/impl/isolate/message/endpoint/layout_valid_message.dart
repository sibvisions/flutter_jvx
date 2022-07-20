import '../../../../../isolate/isolate_message.dart';

class LayoutValidMessage extends IsolateMessage<bool> {
  bool set;
  bool value;

  LayoutValidMessage({required this.set, required this.value});
}
