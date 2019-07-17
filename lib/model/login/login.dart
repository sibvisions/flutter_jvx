import 'package:flutter/widgets.dart';

class Login {
  String username;
  String password;
  String clientId;
  String action;

  Login({this.username, this.password, this.clientId, @required this.action});

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
    "clientId": clientId
  };
}