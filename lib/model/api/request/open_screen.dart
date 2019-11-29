import 'package:jvx_mobile_v3/model/action.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';

/// Model for [OpenScreen] request.
class OpenScreen extends Request {
  bool manualClose;
  Action action;

  OpenScreen({this.manualClose, this.action, String clientId, RequestType requestType}) : super(clientId: clientId, requestType: requestType);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'clientId': clientId,
    'manualClose': manualClose,
    'componentId': action.componentId
  };
}