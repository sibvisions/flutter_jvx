import '../../../utils/device_info.dart';
import '../../../model/api/request/request.dart';

/// Request for the [Startup] request.
class Startup extends Request {
  String applicationName;
  String authKey;
  String layoutMode;
  int screenWidth;
  int screenHeight;
  String appMode;
  int readAheadLimit;
  String deviceId;
  String userName;
  String password;
  String url;
  DeviceInfo deviceInfo;

  Startup(
      {this.applicationName,
      this.authKey,
      this.layoutMode,
      this.screenWidth,
      this.screenHeight,
      this.appMode,
      this.readAheadLimit,
      this.deviceId,
      String clientId,
      this.userName,
      this.password,
      this.url,
      RequestType requestType})
      : super(clientId: clientId, requestType: requestType) {
    this.deviceInfo = DeviceInfo();
  }

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
        'osName': deviceInfo.osName,
        'osVersion': deviceInfo.osVersion,
        'appVersion': deviceInfo.appVersion,
        'deviceType': deviceInfo.deviceType,
        'deviceTypeModel': deviceInfo.deviceTypeModel
      };
}
