import 'package:flutter/foundation.dart';
import 'package:jvx_mobile_v3/model/action.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';

/// Model for the [PressButton] request.
class PressButton extends Request {
  Action action;

  PressButton({@required this.action, String clientId, RequestType requestType})
    : assert(clientId != null), assert(action != null), super(clientId: clientId, requestType: requestType);

  Map<String, dynamic> toJson() => {
    'clientId': clientId,
    'action': action.toJson()
  };
}