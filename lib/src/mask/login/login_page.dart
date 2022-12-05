import 'package:flutter/material.dart';

import '../../flutter_ui.dart';
import '../../model/command/api/login_command.dart';
import '../../model/command/api/reset_password_command.dart';
import '../../service/command/i_command_service.dart';
import '../state/app_style.dart';
import 'default/default_login.dart';
import 'modern/modern_login.dart';

/// Login page of the app, also used for reset/change password
class LoginPage extends StatelessWidget {
  final LoginMode loginMode;

  const LoginPage({
    super.key,
    required this.loginMode,
  });

  @override
  Widget build(BuildContext context) {
    var widget = FlutterUI.of(context)?.loginBuilder?.call(context, loginMode);
    if (widget != null) return widget;

    var appStyle = AppStyle.of(context)!.applicationStyle!;
    String? loginLayout = appStyle['login.layout'];

    if (loginLayout == "modern") {
      return ModernLogin(mode: loginMode);
    } else {
      return DefaultLogin(mode: loginMode);
    }
  }

  /// Sends a [LoginCommand]
  ///
  /// Example error handling:
  /// ```dart
  /// .catchError(IUiService().handleAsyncError);
  /// ```
  static Future<void> doLogin({
    required String username,
    required String password,
    bool createAuthKey = false,
  }) =>
      ICommandService().sendCommand(LoginCommand(
        loginMode: LoginMode.Manual,
        userName: username,
        password: password,
        createAuthKey: createAuthKey,
        reason: "LoginButton",
      ));

  /// Sends a [ResetPasswordCommand]
  ///
  /// Server responses:
  /// * If user logged in, sends message view
  /// * If user not logged in, sends new login view
  static Future<void> doResetPassword({
    required String identifier,
  }) =>
      ICommandService().sendCommand(ResetPasswordCommand(
        identifier: identifier,
        reason: "User reset password",
      ));

  /// Sends a [LoginCommand] with changed password
  ///
  /// Server responses:
  /// * If user logged in, sends message view
  /// * If user not logged in, continues login
  static Future<void> doChangePassword({
    required String username,
    required String password,
    required String newPassword,
  }) =>
      ICommandService().sendCommand(LoginCommand(
        loginMode: LoginMode.ChangePassword,
        userName: username,
        password: password,
        newPassword: newPassword,
        reason: "Password Change",
      ));

  /// Sends a [LoginCommand] with changed password and otp
  ///
  /// Normally the user is logged in after that
  static Future<void> doChangePasswordOTP({
    required String username,
    required String password,
    required String newPassword,
  }) =>
      ICommandService().sendCommand(LoginCommand(
        loginMode: LoginMode.ChangeOneTimePassword,
        userName: username,
        password: password,
        newPassword: newPassword,
        reason: "Password Reset",
      ));
}
