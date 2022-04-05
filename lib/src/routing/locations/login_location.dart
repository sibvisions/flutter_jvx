import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/src/mask/login/app_login.dart';
import 'package:flutter_client/src/mask/login/login_card.dart';
import 'package:flutter_client/src/mask/login/reset_password_card.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';

/// Displays all possible screens the login can show0
class LoginLocation extends BeamLocation<BeamState> with UiServiceMixin {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {

    // Set route context to so popup's can be opened remotely
    uiService.setRouteContext(pContext: context);

    return [
      BeamPage(
        child: AppLogin(loginCard: LoginCard()),
        key: const ValueKey("login")
      ),
      if(state.uri.pathSegments.contains("passwordReset"))
      const BeamPage(
        child: AppLogin(loginCard: ResetPasswordCard()),
        key: ValueKey("login_password_reset")
      )
    ];
  }

  @override
  List<Pattern> get pathPatterns => [
    "/login",
    "/login/passwordReset"
  ];


}