import 'package:jvx_mobile_v3/model/api/request/request.dart';

/// Model for [Login] request.
class Login extends Request{
  String username;
  String password;
  String action;
  bool createAuthKey;

  Login({this.username, this.password, this.action, this.createAuthKey = false, String clientId, RequestType requestType}) : super(clientId: clientId, requestType: requestType);

  Map<String, dynamic> toJson() => {
    "loginData": {
      "userName": {
        "componentId": "UserName",
        "text": username
      },
      "password": {
        "componentId": "Password",
        "text": password
      },
      "action": {
        "componentId": "OK",
        "label": action
      }
    },
    "clientId": clientId,
    "createAuthKey": createAuthKey
  };
}