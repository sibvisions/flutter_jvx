class Login {
  String username;
  String password;

  Login({this.username, this.password});

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password
  };
}