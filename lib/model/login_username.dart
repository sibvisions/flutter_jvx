class LoginUsername {
  String componentId;
  String text;

  LoginUsername({this.componentId, this.text});

  LoginUsername.fromJson(Map<String, dynamic> json)
    : componentId = json['componentId'],
      text = json['text'];
}