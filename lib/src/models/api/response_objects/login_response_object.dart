import 'package:flutterclient/src/models/api/response_object.dart';

class LoginResponseObject extends ResponseObject {
  final String username;

  LoginResponseObject({required String name, required this.username})
      : super(name: name);

  LoginResponseObject.fromJson({required Map<String, dynamic> map})
      : username = map['username'],
        super.fromJson(map: map);
}
