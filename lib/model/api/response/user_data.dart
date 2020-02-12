import '../../../model/api/response/response_object.dart';

class UserData extends ResponseObject {
  String userName;
  String profileImage;
  String displayName;
  List<dynamic> roles;

  UserData({this.userName, this.profileImage, this.displayName, this.roles});

  UserData.fromJson(Map<String, dynamic> json)
    : userName = json['userName'],
      profileImage = json['profileImage'],
      displayName = json['displayName'],
      roles = json['roles'];
}