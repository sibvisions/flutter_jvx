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

    if (mounted) {
      getUiService().setRouteContext(pContext: context);
    }

    return [
      BeamPage(
        child: const AppLogin(loginCard: LoginCard()),
        key: UniqueKey(),
      ),
      if (state.uri.pathSegments.contains("lostPassword"))
        BeamPage(
          child: AppLogin(loginCard: LostPasswordCard()),
          key: const ValueKey("login_password_reset"),
        ),
      if (state.uri.pathSegments.contains("changeOneTimePassword"))
        BeamPage(
          child: AppLogin(
            loginCard: ChangeOneTimePasswordCard(),
          ),
        ),
      if (state.uri.pathSegments.contains("changePassword"))
        BeamPage(
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
  List<Pattern> get pathPatterns =>
      ["/login/manual", "/login/lostPassword", "/login/changeOneTimePassword", "/login/changePassword"];
}
