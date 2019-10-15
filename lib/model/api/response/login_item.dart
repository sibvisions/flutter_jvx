import 'package:jvx_mobile_v3/model/api/response/response_object.dart';
import 'package:jvx_mobile_v3/model/login_data.dart';

class LoginItem extends ResponseObject {
  String componentId;
  LoginData loginData;

  LoginItem({this.componentId, this.loginData});

  LoginItem.fromJson(Map<String, dynamic> json)
    : componentId = json['componentId'],
      loginData = LoginData.fromJson(json['loginData']),
      super.fromJson(json);
}