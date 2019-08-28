import 'package:flutter/foundation.dart';
import 'package:jvx_mobile_v3/model/action.dart';

class PressButton {
  String clientId;
  Action action;

  PressButton({@required this.clientId, @required this.action})
    : assert(clientId != null), assert(action != null);

  Map<String, dynamic> toJson() => {
    'clientId': clientId,
    'action': action.toJson()
  };
}