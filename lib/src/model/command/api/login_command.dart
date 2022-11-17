import 'api_command.dart';

/// All available login request modes
enum LoginMode {
  /// manual login.
  Manual,

  /// change password.
  ChangePassword,

  /// change one-time password.
  ChangeOneTimePassword,

  /// lost password.
  LostPassword,

  /// automatic login.
  Automatic,

  /// multi-factor text input.
  MFTextInput,

  /// multi-factor wait.
  MFWait,

  /// multi-factor URL.
  MFURL,
}

class LoginCommand extends ApiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// See [LoginMode] class
  final LoginMode loginMode;

  /// Username
  final String userName;

  /// Password
  final String password;

  /// Either one-time-password or new password
  final String? newPassword;

  /// "Remember me"
  final bool createAuthKey;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  LoginCommand({
    required this.loginMode,
    required this.userName,
    required this.password,
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
