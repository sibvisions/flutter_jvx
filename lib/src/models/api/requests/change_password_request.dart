import 'package:flutterclient/src/models/api/request.dart';

class ChangePasswordRequest extends Request {
  final String password;
  final String newPassword;
  final String username;

  ChangePasswordRequest(
      {required String clientId,
      required this.password,
      required this.newPassword,
      required this.username})
      : super(clientId: clientId);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'password': password,
        'newPassword': newPassword,
        ...super.toJson()
      };
}
