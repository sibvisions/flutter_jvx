/// Stores all info about the current user
class UserInfo {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name to diplay in the app
  final String displayName;
  /// Username
  final String userName;
  /// Email of the user
  final String? eMail;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  UserInfo({
    required this.userName,
    required this.displayName,
    required this.eMail
  });
}