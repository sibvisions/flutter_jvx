import 'dart:ui';

import '../request.dart';

class DeviceStatus extends Request {
  Size screenSize;
  int screenHeight;
  String timeZoneCode;
  String langCode;

  DeviceStatus({this.screenSize, this.timeZoneCode, this.langCode, String clientId})
    : super(RequestType.DEVICE_STATUS, clientId);

  Map<String, dynamic> toJson() => {
    'clientId': clientId,
    'screenWidth': screenSize.width.round(),
    'screenHeight': screenSize.height.round(),
    'timeZoneCode': timeZoneCode,
    'langCode': langCode
  };
}