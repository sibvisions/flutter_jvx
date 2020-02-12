import '../../../model/api/response/response_object.dart';
import '../../../model/login_data.dart';

class LoginItem extends ResponseObject {
  String componentId;
  LoginData loginData;

  LoginItem({this.componentId, this.loginData});

  LoginItem.fromJson(Map<String, dynamic> json)
    : componentId = json['componentId'],
      loginData = LoginData.fromJson(json['loginData']),
      super.fromJson(json);
}