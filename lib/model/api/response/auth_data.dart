import '../../../model/api/response/response_object.dart';

class AuthenticationData extends ResponseObject {
  String authKey;
  String name;

  AuthenticationData({this.authKey, this.name});

  AuthenticationData.fromJson(Map<String, dynamic> json)
    : authKey = json['authKey'],
      name = json['name'];
}