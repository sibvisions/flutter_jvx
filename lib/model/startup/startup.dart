import 'package:jvx_mobile_v3/model/api/request/request.dart';

/// Request for the [Startup] request.
class Startup extends Request {
  String applicationName;
  String authKey;
  String layoutMode;

  Startup({this.applicationName, this.authKey, this.layoutMode, String clientId, RequestType requestType})
    : super(clientId: clientId, requestType: requestType);

  Map<String, dynamic> toJson() => {
    'applicationName': applicationName,
    'authKey': authKey,
    'layoutMode': layoutMode,
  };
}