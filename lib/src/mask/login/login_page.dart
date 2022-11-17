import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../../../util/image/image_loader.dart';
import '../../../util/parse_util.dart';
import '../../model/command/api/login_command.dart';
import '../../model/command/api/reset_password_command.dart';
import '../setting/widgets/change_password.dart';
import '../state/app_style.dart';
import 'arc_clipper.dart';
import 'cards/change_one_time_password_card.dart';
import 'cards/login_card.dart';
import 'cards/lost_password_card.dart';

/// Login page of the app, also used for reset/change password
class LoginPage extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
      backgroundColor: bottomColor,
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
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Center(
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
              width: MediaQuery.of(context).size.width / 10 * 8,
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
        widget = ChangeOneTimePasswordCard();
        break;
      case LoginMode.ChangeOneTimePassword:
        Map<String, String?>? dataMap = context.currentBeamLocation.data as Map<String, String?>?;
        widget = ChangePassword(
          username: dataMap?.entries.elementAt(0).value,
          password: dataMap?.entries.elementAt(1).value,
        );
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
        reason: "LoginButton",
        createAuthKey: createAuthKey,
      ));

  /// Sends a [ResetPasswordCommand]
  static Future<void> doResetPassword({required String identifier}) =>
      ICommandService().sendCommand(ResetPasswordCommand(
        reason: "User reset password",
        identifier: identifier,
      ));

  /// Sends a [LoginCommand] with changed password and otp
  static Future<void> doChangePasswordOTP({
    required String username,
    required String newPassword,
    required String password,
  }) =>
      ICommandService().sendCommand(LoginCommand(
        loginMode: LoginMode.ChangeOneTimePassword,
        userName: username,
        newPassword: newPassword,
        password: password,
        reason: "Password reset",
      ));
}
