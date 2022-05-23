import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/api/response/api_response.dart';

/// Contains all user specific data
class UserDataResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Unique name
  final String userName;

  /// Name to display
  final String displayName;

  /// Email of the user
  final String? eMail;

  /// Profile image of the user
  final Image? profileImage;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  UserDataResponse({
    required this.displayName,
    required this.userName,
    required this.eMail,
    required this.profileImage,
    required String name,
  }) : super(name: name);

  UserDataResponse.fromJson({required Map<String, dynamic> json})
      : userName = json[ApiObjectProperty.userName],
        displayName = json[ApiObjectProperty.displayName],
        eMail = json[ApiObjectProperty.eMail],
        profileImage = getImage(ApiObjectProperty.profileImage),
        super.fromJson(json);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static Image? getImage(String? data) {
    if (data == null) {
      return null;
    }
    return Image.memory(base64Decode(data));
  }
}
