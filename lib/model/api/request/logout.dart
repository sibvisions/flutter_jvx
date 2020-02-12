import '../../../model/api/request/request.dart';

/// Model for [Logout] request.
class Logout extends Request {
  Logout({String clientId, RequestType requestType}) : super(clientId: clientId, requestType: requestType);

  Map<String, String> toJson() => {
    'clientId': clientId
  };
}