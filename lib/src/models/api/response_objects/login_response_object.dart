import 'package:flutterclient/src/models/api/response_object.dart';

class LoginResponseObject extends ResponseObject {
  final String username;
  final String mode;

  LoginResponseObject(
      {required String name, required this.username, this.mode = 'manual'})
      : super(name: name);

  LoginResponseObject.fromJson({required Map<String, dynamic> map})
      : username = map['username'],
        mode = map['mode'] ?? 'manual',
        super.fromJson(map: map);
}
