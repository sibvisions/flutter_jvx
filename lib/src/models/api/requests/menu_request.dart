import 'package:flutterclient/src/models/api/request.dart';

class MenuRequest extends Request {
  MenuRequest({required String clientId, bool reload = false})
      : super(clientId: clientId, reload: reload);
}
