import 'package:beamer/beamer.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../../mask/login/login_page.dart';
import '../../model/command/api/login_command.dart';

/// Displays all possible screens the login can show0
class LoginLocation extends BeamLocation<BeamState> {
  final ValueNotifier<LoginMode> modeNotifier = ValueNotifier(LoginMode.Manual);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    IUiService().getAppManager()?.onLoginPage();

    _updateLoginMode(state);

    return [
      BeamPage(
        title: FlutterJVx.translate("Login"),
        key: const ValueKey("login"),
        child: ValueListenableBuilder<LoginMode>(
          valueListenable: modeNotifier,
          builder: (context, mode, child) => LoginPage(loginMode: mode),
        ),
      ),
    ];
  }

  void _updateLoginMode(BeamState state) {
    String? mode = state.queryParameters["mode"]?.toLowerCase();
    LoginMode? loginMode;
    if (mode != null) {
      loginMode = LoginMode.values.firstWhereOrNull((e) => e.name.toLowerCase() == mode);
    }
    loginMode ??= LoginMode.Manual;
    if (modeNotifier.value != loginMode) {
      modeNotifier.value = loginMode;
    }
  }

  @override
  List<Pattern> get pathPatterns => [
        "/login",
      ];
}
