import '../request.dart';

class LoginRequest extends Request {
  final String username;
  final String password;
  final bool createAuthKey;

  LoginRequest(
      {required String clientId,
      required this.username,
      required this.password,
      required this.createAuthKey})
      : super(clientId: clientId);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'username': username,
        'password': password,
        'createAuthKey': createAuthKey,
        ...super.toJson()
      };
}
