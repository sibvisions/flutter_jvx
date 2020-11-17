import '../request.dart';
import 'open_screen.dart';

class CloseScreen extends Request {
  String componentId;
  OpenScreen openScreen;

  CloseScreen({this.componentId, this.openScreen, String clientId, RequestType requestType}) : super(requestType, clientId);

  Map<String, String> toJson() => <String, String>{
    'componentId': componentId,
    'clientId': clientId,
  };
}