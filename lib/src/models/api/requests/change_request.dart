import 'package:flutterclient/src/models/api/request.dart';

class ChangeRequest extends Request {
  ChangeRequest({required String clientId, bool reload = false})
      : super(clientId: clientId, reload: reload);
}
