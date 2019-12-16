import 'package:jvx_mobile_v3/model/api/response/response_object.dart';

class UserData extends ResponseObject {
  String userName;
  String profileImage;
  String displayName;

  UserData({this.userName, this.profileImage, this.displayName});

  UserData.fromJson(Map<String, dynamic> json)
    : userName = json['userName'],
      profileImage = json['profileImage'],
      displayName = json['displayName'];
}