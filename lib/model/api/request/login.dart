import '../../../model/api/request/request.dart';

/// Model for [Login] request.
class Login extends Request{
  String username;
  String password;
  bool createAuthKey;

  Login({this.username, this.password, this.createAuthKey = false, String clientId, RequestType requestType}) : super(clientId: clientId, requestType: requestType);

  Map<String, dynamic> toJson() => {
    "username": username,
    "password": password,
    "clientId": clientId,
    "createAuthKey": createAuthKey
  };
}