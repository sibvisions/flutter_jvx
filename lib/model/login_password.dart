class LoginPassword {
  String componentId;
  String text;

  LoginPassword({this.componentId, this.text});

  LoginPassword.fromJson(Map<String, dynamic> json)
    : componentId = json['componentId'],
      text = json['text'];
}