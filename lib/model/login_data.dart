import 'package:jvx_mobile_v3/model/action.dart';
import 'package:jvx_mobile_v3/model/login_password.dart';
import 'package:jvx_mobile_v3/model/login_username.dart';

class LoginData {
  LoginUsername username;
  LoginPassword password;
  Action action;

  LoginData({this.username, this.password, this.action});

  LoginData.fromJson(Map<String, dynamic> json)
    : username = LoginUsername.fromJson(json['userName']),
      password = LoginPassword.fromJson(json['password']),
      action = Action.fromJson(json['action']);
}