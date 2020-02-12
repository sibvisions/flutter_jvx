import '../../../model/action.dart';
import '../../../model/api/request/request.dart';

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