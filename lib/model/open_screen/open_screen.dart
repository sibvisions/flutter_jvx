import 'package:jvx_mobile_v3/model/action.dart';

class OpenScreen {
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