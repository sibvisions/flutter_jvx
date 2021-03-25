import 'package:flutterclient/src/models/api/request.dart';

class MenuRequest extends Request {
  MenuRequest(
      {required String clientId, String? debugInfo, bool reload = false})
      : super(clientId: clientId, debugInfo: debugInfo, reload: reload);
}
