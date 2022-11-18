import 'dart:math';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../../../util/image/image_loader.dart';
import '../../../util/jvx_colors.dart';
import '../../../util/parse_util.dart';
import '../../model/command/api/login_command.dart';
import '../../model/command/api/reset_password_command.dart';
import '../../service/api/shared/api_object_property.dart';
import 'arc_clipper.dart';
import 'cards/change_one_time_password_card.dart';
import 'cards/change_password.dart';
import 'cards/login_card.dart';
import 'cards/lost_password_card.dart';

/// Login page of the app, also used for reset/change password
class LoginPage extends StatelessWidget {
  final LoginMode loginMode;

  const LoginPage({
    super.key,
    required this.loginMode,
  });

  @override
  Widget build(BuildContext context) {
    var widget = FlutterJVx.of(context)?.loginBuilder?.call(context, loginMode);
    if (widget != null) return widget;

    var appStyle = AppStyle.of(context)!.applicationStyle!;
    String? loginLogo = appStyle['login.logo'];

    bool inverseColor = ParseUtil.parseBool(appStyle['login.inverseColor']) ?? false;

    Color? topColor = ParseUtil.parseHexColor(appStyle['login.topColor']) ??
        ParseUtil.parseHexColor(appStyle['login.background']) ??
        Theme.of(context).colorScheme.primary;
    Color? bottomColor = ParseUtil.parseHexColor(appStyle['login.bottomColor']);

    if (inverseColor) {
      var tempTop = topColor;
      topColor = bottomColor;
      bottomColor = tempTop;
    }

    return Scaffold(
      backgroundColor: bottomColor ?? JVxColors.lighten(Theme.of(context).scaffoldBackgroundColor, 0.05),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 4,
                child: ClipPath(
                  clipper: ArcClipper(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: topColor ?? Colors.transparent,
                      gradient: topColor != null
                          ? LinearGradient(
                              begin: Alignment.topCenter,
                              colors: [
                                topColor,
                                JVxColors.lighten(topColor, 0.2),
                              ],
                              end: Alignment.bottomCenter,
                            )
                          : null,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints.loose(const Size.fromWidth(650)),
                        child: loginLogo != null
                            ? ImageLoader.loadImage(loginLogo, pFit: BoxFit.scaleDown)
                            : Image.asset(
                                ImageLoader.getAssetPath(
                                  FlutterJVx.package,
                                  "assets/images/branding_sib_visions.png",
                                ),
                                fit: BoxFit.scaleDown,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: ColoredBox(
                  color: bottomColor ?? Colors.transparent,
                ),
              ),
            ],
          ),
          Center(
            child: SizedBox(
              width: min(600, MediaQuery.of(context).size.width / 10 * 8),
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: SingleChildScrollView(
                  // Is there to allow scrolling the login if there is not enough space.
                  // E.g.: Holding a phone horizontally and trying to login needs scrolling to be possible.
                  child: Card(
                    color: Theme.of(context).cardColor.withOpacity(0.9),
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildCard(context, loginMode),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildCard(BuildContext context, LoginMode? loginMode) {
    Widget widget;
    switch (loginMode) {
      case LoginMode.LostPassword:
        widget = LostPasswordCard();
        break;
      case LoginMode.ChangePassword:
        Map<String, String?>? dataMap = context.currentBeamLocation.data as Map<String, String?>?;
        widget = ChangePassword(
          username: dataMap?[ApiObjectProperty.username],
          password: dataMap?[ApiObjectProperty.password],
        );
        break;
      case LoginMode.ChangeOneTimePassword:
        widget = ChangeOneTimePasswordCard();
        break;
      case LoginMode.Manual:
      default:
        widget = const LoginCard();
        break;
    }
    return widget;
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
