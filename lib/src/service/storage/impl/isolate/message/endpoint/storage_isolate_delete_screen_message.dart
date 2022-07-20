import '../../../../../isolate/isolate_message.dart';

class StorageIsolateDeleteScreenMessage extends IsolateMessage {
  final String screenName;

  StorageIsolateDeleteScreenMessage({required this.screenName});
}
