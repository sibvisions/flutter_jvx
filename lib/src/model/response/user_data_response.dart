import 'dart:convert';

import 'package:flutter/material.dart';

import '../../service/api/shared/api_object_property.dart';
import 'api_response.dart';

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
    required Object originalRequest,
  }) : super(name: name, originalRequest: originalRequest);

  UserDataResponse.fromJson({required Map<String, dynamic> pJson, required Object originalRequest})
      : userName = pJson[ApiObjectProperty.userName],
        displayName = pJson[ApiObjectProperty.displayName],
        eMail = pJson[ApiObjectProperty.eMail],
        profileImage = getImage(pJson[ApiObjectProperty.profileImage]),
        super.fromJson(pJson: pJson, originalRequest: originalRequest);

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
