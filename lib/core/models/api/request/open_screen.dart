import '../request.dart';
import '../so_action.dart';

class OpenScreen extends Request {
  bool manualClose;
  SoAction action;

  @override
  String get debugInfo {
    return action.componentId;
  }

  OpenScreen(
      {this.manualClose, this.action, String clientId, RequestType requestType})
      : super(requestType, clientId);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'clientId': clientId,
        'manualClose': manualClose,
        'componentId': action.componentId
      };
}
