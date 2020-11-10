import '../request.dart';

class Logout extends Request {
  Logout({String clientId, RequestType requestType}) : super(requestType, clientId);

  Map<String, String> toJson() => {
    'clientId': clientId
  };
}