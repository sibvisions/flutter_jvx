import 'package:flutter/foundation.dart';

import '../../../utils/device_info/device_info.dart';
import '../request.dart';

class Startup extends Request {
  final String applicationName;
  final String authKey;
  final String layoutMode;
  final int screenWidth;
  final int screenHeight;
  final String appMode;
  final int readAheadLimit;
  final String deviceId;
  final String userName;
  final String password;
  final String url;
  final DeviceInfo deviceInfo;
  final String deviceMode;

  Startup(
      {RequestType requestType,
      String clientId,
      this.applicationName,
      this.authKey,
      this.layoutMode = 'generic',
      this.screenWidth,
      this.screenHeight,
      this.appMode,
      this.readAheadLimit,
      this.deviceId,
      this.userName,
      this.password,
      this.url})
      : this.deviceInfo = DeviceInfo(),
        this.deviceMode = kIsWeb ? 'desktop' : 'mobile',
        super(requestType, clientId);

  @override
  Map<String, dynamic> toJson() => {
        'applicationName': applicationName,
        'authKey': authKey,
        'layoutMode': layoutMode,
        'screenWidth': screenWidth,
        'screenHeight': screenHeight,
        'appMode': appMode,
        'readAheadLimit': readAheadLimit,
        'deviceId': deviceId,
        'userName': userName,
        'password': password,
        'url': url,
        'technology': deviceInfo.technology,
        'osName': deviceInfo.osName,
        'osVersion': deviceInfo.osVersion,
        'appVersion': deviceInfo.appVersion,
        'deviceType': deviceInfo.deviceType,
        'deviceTypeModel': deviceInfo.deviceTypeModel,
        'deviceMode': this.deviceMode
      };
}
