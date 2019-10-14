
import 'package:flutter/foundation.dart';
import 'package:jvx_mobile_v3/model/action.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

/// Model for the [PressButton] request.
class PressButton extends Request {
  String clientId;
  Action action;

  PressButton(this.action)  : 
      super(clientId: globals.clientId, requestType: RequestType.PRESS_BUTTON);

  Map<String, dynamic> toJson() => {
    'clientId': clientId,
    'action': action.toJson()
  };
}