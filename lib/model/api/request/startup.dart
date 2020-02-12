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

  Startup({this.applicationName, this.authKey, this.layoutMode, this.screenWidth, this.screenHeight, this.appMode, this.readAheadLimit, this.deviceId, String clientId, RequestType requestType})
    : super(clientId: clientId, requestType: requestType);

  Map<String, dynamic> toJson() => {
    'applicationName': applicationName,
    'authKey': authKey,
    'layoutMode': layoutMode,
    'screenWidth': screenWidth,
    'screenHeight': screenHeight,
    'appMode': appMode,
    'readAheadLimit': readAheadLimit,
    'deviceId': deviceId
  };
}