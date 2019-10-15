import 'package:jvx_mobile_v3/model/api/request/request.dart';

/// Model for the [CloseScreen] request.
class CloseScreen extends Request {
  String componentId;

  CloseScreen({this.componentId, String clientId, RequestType requestType}) : super(clientId: clientId, requestType: requestType);

  Map<String, String> toJson() => <String, String>{
    'componentId': componentId,
    'clientId': clientId,
  };
}