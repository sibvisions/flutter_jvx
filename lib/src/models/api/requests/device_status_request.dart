import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/api/request.dart';

class DeviceStatusRequest extends Request {
  Size screenSize;
  String timeZoneCode;
  String langCode;

  @override
  String get debugInfo =>
      'clientId: $clientId, screenSize: $screenSize, timeZoneCode: $timeZoneCode, langCode: $langCode';

  DeviceStatusRequest({
    required String clientId,
    bool reload = false,
    required this.screenSize,
    required this.timeZoneCode,
    required this.langCode,
  }) : super(clientId: clientId, reload: reload);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'screenWidth': screenSize.width.round(),
        'screenHeight': screenSize.height.round(),
        'timeZoneCode': timeZoneCode,
        'langCode': langCode,
        ...super.toJson()
      };
}
