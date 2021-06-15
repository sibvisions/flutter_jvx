import '../request.dart';

class LoginRequest extends Request {
  final String username;
  final String password;
  final bool createAuthKey;
  final String newPassword;

  LoginRequest(
      {required String clientId,
      required this.username,
      required this.password,
      required this.createAuthKey,
      this.newPassword = ''})
      : super(clientId: clientId);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'username': username,
        'password': password,
        'createAuthKey': createAuthKey,
        if (newPassword.isNotEmpty) 'newPassword': newPassword,
        ...super.toJson()
      };
}
