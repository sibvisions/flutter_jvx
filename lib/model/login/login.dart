class Login {
  String username;
  String password;
  String clientId;
  String action;
  bool createAuthKey;

  Login({this.username, this.password, this.clientId, this.action, this.createAuthKey = false});

  Map<String, dynamic> toJson() => {
    "loginData": {
      "userName": {
        "componentId": "UserName",
        "text": username
      },
      "password": {
        "componentId": "Password",
        "text": password
      },
      "action": {
        "componentId": "OK",
        "label": action
      }
    },
    "clientId": clientId,
    "createAuthKey": createAuthKey
  };
}