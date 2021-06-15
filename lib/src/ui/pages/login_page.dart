import 'package:flutter/material.dart';

import '../../../injection_container.dart';
import '../../models/state/app_state.dart';
import '../../services/local/shared_preferences/shared_preferences_manager.dart';
import '../../util/theme/theme_manager.dart';
import '../widgets/page/login/login_card.dart';
import '../widgets/page/login/login_page_widget.dart';

class LoginPage extends StatelessWidget {
  final AppState appState;
  final SharedPreferencesManager manager;
  final String? lastUsername;
  final LoginMode loginMode;

  const LoginPage(
      {Key? key,
      required this.appState,
      required this.manager,
      required this.loginMode,
      this.lastUsername})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Theme(
        data: sl<ThemeManager>().value,
        child: LoginPageWidget(
          appState: appState,
          manager: manager,
          lastUsername: lastUsername,
          loginMode: loginMode,
        ),
      ),
    );
  }
}
