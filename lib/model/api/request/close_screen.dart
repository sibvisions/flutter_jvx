import '../../../model/api/request/open_screen.dart';
import '../../../model/api/request/request.dart';

/// Model for the [CloseScreen] request.
class CloseScreen extends Request {
  String componentId;
  OpenScreen openScreen;

  CloseScreen({this.componentId, this.openScreen, String clientId, RequestType requestType}) : super(clientId: clientId, requestType: requestType);

  Map<String, String> toJson() => <String, String>{
    'componentId': componentId,
    'clientId': clientId,
  };
}