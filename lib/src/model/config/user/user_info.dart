import 'package:flutter/material.dart';

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
  final Image? profileImage;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  UserInfo({
    required this.userName,
    required this.displayName,
    required this.eMail,
    required this.profileImage,
  });
}
