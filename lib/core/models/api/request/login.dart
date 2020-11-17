import '../request.dart';

class Login extends Request{
  String username;
  String password;
  bool createAuthKey;

  Login({this.username, this.password, this.createAuthKey = false, String clientId, RequestType requestType}) : super(requestType, clientId);

  Map<String, dynamic> toJson() => {
    "username": username,
    "password": password,
    "clientId": clientId,
    "createAuthKey": createAuthKey
  };
}