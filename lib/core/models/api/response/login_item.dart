import '../response_object.dart';

class LoginItem extends ResponseObject {
  String componentId;
  String username;

  LoginItem({this.componentId, this.username});

  LoginItem.fromJson(Map<String, dynamic> json)
      : componentId = json['componentId'],
        username = json['username'],
        super.fromJson(json);
}
