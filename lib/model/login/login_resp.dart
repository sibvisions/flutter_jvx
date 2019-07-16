import 'package:jvx_mobile_v3/model/login_data.dart';

class CreateLoginResponse {
  String status;
  CreateLoginResponse({this.status});

  CreateLoginResponse.fromJson(Map<String, dynamic> json)
    : status = json['status'];
}

class LoginResponse {
  String status;
  LoginData data;
  LoginResponse({this.status, this.data});

  LoginResponse.fromJson(Map<String, dynamic> json)
    : status = json['status'],
      data = LoginData.fromJson(json['data']);
}
