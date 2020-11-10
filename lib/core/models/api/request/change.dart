import '../request.dart';

class Change extends Request {
  Change({String clientId, RequestType requestType})
      : super(requestType, clientId);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'clientId': clientId};
}
