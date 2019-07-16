import 'package:jvx_mobile_v3/model/login_data.dart';

class LoginItem {
  String name;
  String componentId;
  LoginData loginData;

  LoginItem({this.name, this.componentId, this.loginData});

  LoginItem.fromJson(Map<String, dynamic> json)
    : name = json['name'],
      componentId = json['componentId'],
      loginData = LoginData.fromJson(json['loginData']);
}