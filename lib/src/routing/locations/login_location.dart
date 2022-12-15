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

import 'package:beamer/beamer.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import '../../flutter_ui.dart';
import '../../mask/login/login_page.dart';
import '../../model/command/api/login_command.dart';
import '../../service/ui/i_ui_service.dart';

/// Displays all possible screens the login can show0
class LoginLocation extends BeamLocation<BeamState> {
  final ValueNotifier<LoginMode> modeNotifier = ValueNotifier(LoginMode.Manual);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    IUiService().getAppManager()?.onLoginPage();

    _updateLoginMode(state);

    return [
      BeamPage(
        title: FlutterUI.translate("Login"),
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
