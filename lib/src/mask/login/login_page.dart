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

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../flutter_ui.dart';
import '../../model/command/api/cancel_login_command.dart';
import '../../model/command/api/login_command.dart';
import '../../model/command/api/logout_command.dart';
import '../../model/command/api/reset_password_command.dart';
import '../../model/command/ui/route/route_to_login_command.dart';
import '../../service/apps/i_app_service.dart';
import '../../service/command/i_command_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/jvx_colors.dart';
import '../../util/widgets/jvx_webview.dart';
import '../state/app_style.dart';
import 'default/default_login.dart';
import 'modern/modern_login.dart';

/// Login page of the app, also used for reset/change password
class LoginPage extends StatefulWidget {
  final LoginMode loginMode;

  const LoginPage({
    super.key,
    required this.loginMode,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();

  /// Routes to the login page with the specified login mode.
  ///
  /// This method **does not** clear touch any session data, this is just routing,
  /// for a logout use [LogoutCommand] instead.
  static void update(LoginData loginData) {
      FlutterUI.getBeamerDelegate().beamToReplacementNamed("/login", data: loginData);
  }

  /// Sends a normal [LoginCommand].
  ///
  /// Example error handling:
  /// ```dart
  /// .catchError(IUiService().handleAsyncError);
  /// ```
  static Future<bool> doLogin({
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
  static Future<bool> doMFALogin({
    LoginMode mode = LoginMode.MFTextInput,
    String? username,
    String? password,
    String? confirmationCode,
    bool createAuthKey = false,
  }) =>
      ICommandService().sendCommand(
        LoginCommand(
          loginMode: mode,
          username: username,
          password: password,
          confirmationCode: confirmationCode,
          createAuthKey: createAuthKey,
          reason: "LoginButton",
        ),
      );

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
        showBarModalBottomSheet(
        barrierColor: JVxColors.LIGHTER_BLACK.withAlpha(Color.getAlphaFromOpacity(0.75)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: const RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.only(topLeft: kDefaultBarTopRadius, topRight: kDefaultBarTopRadius),
        ),
        topControl: Container(),
        context: context,
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(FlutterUI.translate("Verification")),
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
          ),
          body: JVxWebView(
            initialUrl: uri,
          ),
        ),
        isDismissible: false,
        enableDrag: false,
        expand: true,
        bounce: false,
      );
    }
  }

  /// Sends a [CancelLoginCommand]
  ///
  /// Example error handling:
  /// ```dart
  /// .catchError(IUiService().handleAsyncError);
  /// ```
  static Future<bool> cancelLogin() {
    return ICommandService().sendCommand(CancelLoginCommand(
      reason: "User canceled login",
    ));
  }

  /// Sends a [ResetPasswordCommand]
  ///
  /// [identifier] can be either an e-mail address or a username which identifies the user.
  ///
  /// Server responses:
  /// * If user logged in, sends message view
  /// * If user not logged in, sends new login view
  static Future<bool> doResetPassword({
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
  static Future<bool> doChangePassword({
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
  static Future<bool> doChangePasswordOTP({
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

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    var customWidget = FlutterUI.of(context).widget.loginHandler?.builder?.call(context, widget.loginMode);
    if (customWidget != null) return customWidget;

    AppStyle appStyle = AppStyle.of(context);
    String? loginLayout = appStyle.style(context, AppStyle.loginLayout);

    Widget login;

    loginLayout = "modern";

    if (loginLayout == "modern") {
      login = ModernLogin(mode: widget.loginMode);
    } else {
      login = DefaultLogin(mode: widget.loginMode);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        if (IUiService().canRouteToAppOverview() && IAppService().wasStartedManually()) {
          unawaited(IUiService().routeToAppOverview());
        }
      },
      child: login
    );
  }
}
