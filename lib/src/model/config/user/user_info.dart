import 'dart:convert';
import 'dart:typed_data';

import '../../../service/api/shared/api_object_property.dart';

/// Stores all info about the current user
class UserInfo {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name to display in the app
  final String? displayName;

  /// Username
  final String? userName;

  /// Email of the user
  final String? eMail;

  /// Profile image
  final Uint8List? profileImage;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  UserInfo({
    required this.userName,
    required this.displayName,
    required this.eMail,
    required String? profileImage,
  }) : profileImage = _decode(profileImage);

  UserInfo.fromJson({required Map<String, dynamic> pJson})
      : userName = pJson[ApiObjectProperty.userName],
        displayName = pJson[ApiObjectProperty.displayName],
        eMail = pJson[ApiObjectProperty.eMail],
        profileImage = _decode(pJson[ApiObjectProperty.profileImage]);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static Uint8List? _decode(String? data) {
    if (data == null) {
      return null;
    }
    return base64Decode(data);
  }
}
