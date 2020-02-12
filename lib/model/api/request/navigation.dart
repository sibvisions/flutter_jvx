import '../../../model/api/request/request.dart';

class Navigation extends Request {
  String componentId;

  Navigation({this.componentId, String clientId}) : super(clientId: clientId, requestType: RequestType.NAVIGATION);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'componentId': componentId,
    'clientId': clientId
  };  
}