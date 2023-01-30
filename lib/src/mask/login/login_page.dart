/* 
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../flutter_ui.dart';
import '../../model/command/api/cancel_login_command.dart';
import '../../model/command/api/login_command.dart';
import '../../model/command/api/reset_password_command.dart';
import '../../service/command/i_command_service.dart';
import '../../service/config/config_controller.dart';
import '../../util/jvx_webview.dart';
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
    var widget = FlutterUI.of(context).widget.loginBuilder?.call(context, loginMode);
    if (widget != null) return widget;

    var appStyle = AppStyle.of(context).applicationStyle;
    String? loginLayout = appStyle['login.layout'];

    if (loginLayout == "modern") {
      return ModernLogin(mode: loginMode);
    } else {
      return DefaultLogin(mode: loginMode);
    }
  }

  /// Sends a normal [LoginCommand].
  ///
  /// Example error handling:
  /// ```dart
  /// .catchError(IUiService().handleAsyncError);
  /// ```
  static Future<void> doLogin({
    LoginMode mode = LoginMode.Manual,
    required String username,
    required String password,
    bool createAuthKey = false,
  }) =>
      ICommandService().sendCommand(LoginCommand(
        loginMode: mode,
        username: username,
        password: password,
        createAuthKey: createAuthKey,
        reason: "LoginButton",
      ));

  /// Sends a MFA [LoginCommand].
  ///
  /// In most cases only [confirmationCode] is required.
  /// [username] and [password] are auto-filled by the values
  /// from the last login attempt.
  ///
  /// Example error handling:
  /// ```dart
  /// .catchError(IUiService().handleAsyncError);
  /// ```
  static Future<void> doMFALogin({
    LoginMode mode = LoginMode.MFTextInput,
    String? username,
    String? password,
    String? confirmationCode,
    bool createAuthKey = false,
  }) =>
      ICommandService().sendCommand(LoginCommand(
        loginMode: mode,
        username: username ?? ConfigController().username.value,
        password: password ?? ConfigController().password.value,
        confirmationCode: confirmationCode,
        createAuthKey: createAuthKey,
        reason: "LoginButton",
      ));

  /// Sends a MFA [LoginCommand].
  ///
  /// In most cases only [confirmationCode] is required.
  /// [username] and [password] are auto-filled by the values
  /// from the last login attempt.
  ///
  /// Example error handling:
  /// ```dart
  /// .catchError(IUiService().handleAsyncError);
  /// ```
  static void openMFAURL(
    BuildContext context, {
    required String url,
  }) {
    Uri uri = Uri.parse(url);
    if (kIsWeb) {
      launchUrl(
        uri,
        webOnlyWindowName: FlutterUI.translate("Verification"),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(FlutterUI.translate("Verification")),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
          ),
          body: JVxWebView(
            initialUrl: uri,
          ),
        ),
        barrierDismissible: false,
      );
    }
  }

  /// Sends a [CancelLoginCommand]
  ///
  /// Example error handling:
  /// ```dart
  /// .catchError(IUiService().handleAsyncError);
  /// ```
  static Future<void> cancelLogin() {
    return ICommandService().sendCommand(CancelLoginCommand(
      reason: "User canceled login",
    ));
  }

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
        username: username,
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
        username: username,
        password: password,
        newPassword: newPassword,
        reason: "Password Reset",
      ));
}
