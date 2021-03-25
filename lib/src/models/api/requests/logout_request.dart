import 'package:flutterclient/src/models/api/request.dart';

class LogoutRequest extends Request {
  LogoutRequest({required String clientId}) : super(clientId: clientId);
}
