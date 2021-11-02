class LoginRequest {
  final String username;
  final String password;
  final String clientId;

  LoginRequest({
    required this.username,
    required this.password,
    required this.clientId
  });


  Map<String, dynamic> toJson() => {
    _PLoginRequest.clientId: clientId,
    _PLoginRequest.password: password,
    _PLoginRequest.username: username,
  };

}

abstract class _PLoginRequest {
  static const username = "username";
  static const password = "password";
  static const clientId = "clientId";
}

