import 'package:flutterclient/src/models/api/request.dart';

class ChangePasswordRequest extends Request {
  final String password;
  final String newPassword;

  ChangePasswordRequest(
      {required String clientId,
      required this.password,
      required this.newPassword})
      : super(clientId: clientId);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'password': password,
        'newpassword': newPassword,
        ...super.toJson()
      };
}
