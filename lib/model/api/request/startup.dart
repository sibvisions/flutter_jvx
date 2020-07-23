import 'package:flutter/foundation.dart';
import 'package:universal_io/prefer_universal/io.dart';

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
  String technology;

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
    this.technology = "FlutterMobile";
    if (kIsWeb) this.technology = "FlutterWeb";
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
        'technology': technology
      };
}
