import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/src/mask/login/app_login.dart';
import 'package:flutter_client/src/mask/login/change_one_time_password_card.dart';
import 'package:flutter_client/src/mask/login/login_card.dart';
import 'package:flutter_client/src/mask/login/lost_password_card.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';

/// Displays all possible screens the login can show0
class LoginLocation extends BeamLocation<BeamState> with UiServiceMixin {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {

    return [
      BeamPage(
        child: AppLogin(loginCard: LoginCard()),
        key: const ValueKey("login")
      ),
      if(state.uri.pathSegments.contains("lostPassword"))
      BeamPage(
        child: AppLogin(loginCard: LostPasswordCard()),
        key: const ValueKey("login_password_reset")
      ),
      if(state.uri.pathSegments.contains("changeOneTimePassword"))
      BeamPage(
        child: AppLogin(loginCard: ChangeOneTimePasswordCard())
      )
    ];
  }

  @override
  List<Pattern> get pathPatterns => [
    "/login",
    "/login/lostPassword",
    "/login/changeOneTimePassword"
  ];


}