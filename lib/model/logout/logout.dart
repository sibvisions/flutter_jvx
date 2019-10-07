import 'package:jvx_mobile_v3/model/api/request/request.dart';

/// Model for [Logout] request.
class Logout extends Request {
  String clientId;

  Logout({this.clientId});

  Map<String, String> toJson() => {
    'clientId': clientId
  };
}