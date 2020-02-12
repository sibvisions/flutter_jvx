import '../../../model/api/request/request.dart';

class Change extends Request {
  Change({String clientId, RequestType requestType}) : super(clientId: clientId, requestType: requestType);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'clientId': clientId
  };
}