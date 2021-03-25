import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/state/app_state.dart';
import 'package:flutterclient/src/services/local/shared_preferences/shared_preferences_manager.dart';
import 'package:flutterclient/src/ui/widgets/page/login/login_page_widget.dart';

import '../../../injection_container.dart';
import '../../util/theme/theme_manager.dart';

class LoginPage extends StatelessWidget {
  final AppState appState;
  final SharedPreferencesManager manager;
  final String? lastUsername;

  const LoginPage(
      {Key? key,
      required this.appState,
      required this.manager,
      this.lastUsername})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: sl<ThemeManager>().value,
      child: LoginPageWidget(
        appState: appState,
        manager: manager,
        lastUsername: lastUsername,
      ),
    );
  }
}
