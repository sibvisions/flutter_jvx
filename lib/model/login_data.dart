import 'so_action.dart';
import '../model/login_password.dart';
import '../model/login_username.dart';

class LoginData {
  LoginUsername username;
  LoginPassword password;
  SoAction action;

  LoginData({this.username, this.password, this.action});

  LoginData.fromJson(Map<String, dynamic> json)
      : username = LoginUsername.fromJson(json['userName']),
        password = LoginPassword.fromJson(json['password']),
        action = SoAction.fromJson(json['action']);
}
