import 'package:flutterclient/src/models/api/response_object.dart';

class UserDataResponseObject extends ResponseObject {
  final String username;
  final String profileImage;
  final String displayName;
  final List<dynamic> roles;

  UserDataResponseObject(
      {required String name,
      required this.username,
      required this.profileImage,
      required this.displayName,
      required this.roles})
      : super(name: name);

  UserDataResponseObject.fromJson({required Map<String, dynamic> map})
      : username = map['userName'],
        profileImage = map['profileImage'] ?? '',
        displayName = map['displayName'],
        roles = map['roles'],
        super.fromJson(map: map);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userName': username,
        'profileImage': profileImage,
        'displayName': displayName,
        'roles': roles,
        ...super.toJson()
      };
}
