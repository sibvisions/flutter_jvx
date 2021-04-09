import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/api/request.dart';

class DeviceStatusRequest extends Request {
  Size screenSize;
  String timeZoneCode;
  String langCode;

  DeviceStatusRequest({
    required String clientId,
    String? debugInfo,
    bool reload = false,
    required this.screenSize,
    required this.timeZoneCode,
    required this.langCode,
  }) : super(clientId: clientId, debugInfo: debugInfo, reload: reload);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'screenWidth': screenSize.width.round(),
        'screenHeight': screenSize.height.round(),
        'timeZoneCode': timeZoneCode,
        'langCode': langCode,
        ...super.toJson()
      };
}
