import '../../../model/api/request/request.dart';

class Reload extends Request {
  Reload({RequestType requestType, String clientId})
      : super(requestType: requestType, clientId: clientId);

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    return null;
  }
}
