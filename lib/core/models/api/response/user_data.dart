import '../response_object.dart';

class UserData extends ResponseObject {
  String userName;
  String profileImage;
  String displayName;
  List<dynamic> roles;

  bool hasRole(String role) => this.roles != null && this.roles.isNotEmpty
      ? this.roles.contains(role)
      : false;

  UserData({this.userName, this.profileImage, this.displayName, this.roles});

  UserData.fromJson(Map<String, dynamic> json)
      : userName = json['userName'],
        profileImage = json['profileImage'],
        displayName = json['displayName'],
        roles = json['roles'];
}
