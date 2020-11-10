import '../request.dart';

class Reload extends Request {
  Reload({RequestType requestType, String clientId})
      : super(requestType, clientId);

  @override
  Map<String, dynamic> toJson() {
    return null;
  }
}
