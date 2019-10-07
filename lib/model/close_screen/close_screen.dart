import 'package:jvx_mobile_v3/model/api/request/request.dart';

/// Model for the [CloseScreen] request.
class CloseScreen extends Request {
  String componentId;
  String clientId;

  CloseScreen({this.componentId, this.clientId});

  Map<String, String> toJson() => <String, String>{
    'componentId': componentId,
    'clientId': clientId
  };
}