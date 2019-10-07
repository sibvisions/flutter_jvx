import 'package:jvx_mobile_v3/model/action.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';

/// Model for [OpenScreen] request.
class OpenScreen extends Request {
  String clientId;
  bool manualClose;
  Action action;

  OpenScreen({this.clientId, this.manualClose, this.action});

  Map<String, dynamic> toJson() => <String, dynamic>{
    'clientId': clientId,
    'manualClose': manualClose,
    'action': action.toJson()
  };
}