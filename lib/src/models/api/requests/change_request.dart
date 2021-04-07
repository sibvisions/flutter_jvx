import 'package:flutterclient/src/models/api/request.dart';

class ChangeRequest extends Request {
  ChangeRequest(
      {required String clientId, String? debugInfo, bool reload = false})
      : super(clientId: clientId, debugInfo: debugInfo, reload: reload);
}
