import 'dart:ui';

import '../../../model/api/request/request.dart';
import '../../../utils/globals.dart' as globals;

/// Request for the [Startup] request.
class DeviceStatus extends Request {
  Size screenSize;
  int screenHeight;
  String timeZoneCode;
  String langCode;

  DeviceStatus({this.screenSize, this.timeZoneCode, this.langCode})
    : super(clientId: globals.clientId, requestType: RequestType.DEVICE_STATUS);

  Map<String, dynamic> toJson() => {
    'clientId': clientId,
    'screenWidth': screenSize.width.round(),
    'screenHeight': screenSize.height.round(),
    'timeZoneCode': timeZoneCode,
    'langCode': langCode
  };
}