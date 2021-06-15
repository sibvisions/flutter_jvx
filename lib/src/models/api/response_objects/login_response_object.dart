import 'package:flutterclient/src/models/api/response_object.dart';

class LoginResponseObject extends ResponseObject {
  final String username;
  final bool changePassword;

  LoginResponseObject(
      {required String name,
      required this.username,
      this.changePassword = false})
      : super(name: name);

  LoginResponseObject.fromJson({required Map<String, dynamic> map})
      : username = map['username'],
        changePassword = map['changePassword'] ?? false,
        super.fromJson(map: map);
}
