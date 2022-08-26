import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

import '../../../mixin/ui_service_mixin.dart';
import '../../mask/login/app_login.dart';
import '../../mask/login/change_one_time_password_card.dart';
import '../../mask/login/login_card.dart';
import '../../mask/login/lost_password_card.dart';
import '../../mask/setting/widgets/change_password.dart';

/// Displays all possible screens the login can show0
class LoginLocation extends BeamLocation<BeamState> with UiServiceGetterMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    Map<String, String?>? dataMap = data as Map<String, String?>?;

    return [
      const BeamPage(
        key: ValueKey("login"),
        child: AppLogin(loginCard: LoginCard()),
      ),
      if (state.uri.pathSegments.contains("lostPassword"))
        BeamPage(
          key: const ValueKey("login_password_reset"),
          child: AppLogin(loginCard: LostPasswordCard()),
        ),
      if (state.uri.pathSegments.contains("changeOneTimePassword"))
        BeamPage(
          key: const ValueKey("login_password_reset"),
          child: AppLogin(loginCard: ChangeOneTimePasswordCard()),
        ),
      if (state.uri.pathSegments.contains("changePassword"))
        BeamPage(
          key: const ValueKey("change_password"),
          child: AppLogin(
            loginCard: ChangePassword(
              username: dataMap?.entries.elementAt(0).value,
              password: dataMap?.entries.elementAt(1).value,
            ),
          ),
        ),
    ];
  }

  @override
  List<Pattern> get pathPatterns => [
        "/login/manual",
        "/login/lostPassword",
        "/login/changeOneTimePassword",
        "/login/changePassword",
      ];
}
