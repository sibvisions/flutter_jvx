import 'api_command.dart';

/// All available login request modes
class LoginMode {
  static const String MANUAL = "manual";
  static const String CHANGE_PASSWORD = "changePassword";
  static const String CHANGE_ONE_TIME_PASSWORD = "changeOneTimePassword";
  static const String AUTOMATIC = "automatic";
  static const String LOST_PASSWORD = "lostPassword";
}

class LoginCommand extends ApiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Username
  final String userName;

  /// Password
  final String password;

  /// Either one-time-password or new password
  final String? newPassword;

  /// See [LoginMode] class
  final String loginMode;

  /// "Remember me"
  final bool createAuthKey;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  LoginCommand({
    required this.userName,
    required this.password,
    required this.loginMode,
    this.createAuthKey = false,
    this.newPassword,
    required super.reason,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "LoginCommand{userName: $userName, loginMode: $loginMode, createAuthKey: $createAuthKey, ${super.toString()}}";
  }
}
