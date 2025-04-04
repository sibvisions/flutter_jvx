/*
 * Copyright 2022-2023 SIB Visions GmbH
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
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../flutter_ui.dart';
import '../../mask/apps/app_overview_page.dart';
import '../../mask/login/login_page.dart';
import '../../mask/menu/menu_page.dart';
import '../../mask/setting/settings_page.dart';
import '../../mask/work_screen/work_screen_page.dart';
import '../../model/command/api/login_command.dart';
import '../../service/apps/i_app_service.dart';
import '../../service/ui/i_ui_service.dart';

/// Displays all possible screens of the menu
class MainLocation extends BeamLocation<BeamState> {
  final ValueNotifier<LoginMode> loginModeNotifier = ValueNotifier(LoginMode.Manual);
  static const screenNameKey = "workScreenName";

  /// The global return URI key used in [BeamState.queryParameters].
  ///
  /// Used for return URIs that are supposed to survive app (re-)starts.
  /// For example, deep-links and web-reloads.
  ///
  /// See also:
  /// * [BeamGuard] in [FlutterUI].
  /// * [IAppService.getApplicableReturnUri]
  static const returnUriKey = "returnUri";

  BeamPage? lastPage;

  BeamPageType get beamPageType => kIsWeb ? BeamPageType.noTransition : BeamPageType.material;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    FlutterUI.logUI.d("Building main location");

    List<BeamPage> pages = [];

    if (state.pathPatternSegments.isEmpty || IAppService().wasStartedManually()) {
      pages.add(
        BeamPage(
          title: AppOverviewPage.appsOrAppText,
          key: const ValueKey("app_overview"),
          child: const AppOverviewPage(),
          type: beamPageType,
        ),
      );
    }

    if (state.pathPatternSegments.contains("login")) {
      IUiService().getAppManager()?.onLoginPage();
      _updateLoginMode(state);

      pages.add(
        BeamPage(
          title: FlutterUI.translate("Login"),
          key: const ValueKey("login"),
          type: beamPageType,
          child: ValueListenableBuilder<LoginMode>(
            valueListenable: loginModeNotifier,
            builder: (context, mode, child) => LoginPage(loginMode: mode),
          ),
        ),
      );
    }

    if (state.pathPatternSegments.contains("home") || state.pathPatternSegments.contains("screens")) {
      final String? workScreenName = state.pathParameters[screenNameKey];
      pages.addAll([
        BeamPage(
          title: FlutterUI.translate("Menu"),
          key: const ValueKey("Menu"),
          type: beamPageType,
          child: const MenuPage(),
        ),
        if (workScreenName != null)
          BeamPage(
            title: FlutterUI.translate("Workscreen"),
            key: ValueKey(workScreenName),
            type: beamPageType,
            child: WorkScreenPage(
              screenName: workScreenName,
            ),
          ),
      ]);
    }

    // Global page.
    if (state.pathPatternSegments.contains("settings")) {
      return [
        if (lastPage != null) lastPage!,
        BeamPage(
          title: FlutterUI.translate("Settings"),
          key: const ValueKey("Settings"),
          type: beamPageType,
          child: const SettingsPage(),
          onPopPage: BeamPage.routePop,
        ),
      ];
    }

    lastPage = pages.lastOrNull;

    return pages;
  }

  void _updateLoginMode(BeamState state) {
    String? mode = state.queryParameters["mode"]?.toLowerCase();
    LoginMode? loginMode;
    if (mode != null) {
      loginMode = LoginMode.values.firstWhereOrNull((e) => e.name.toLowerCase() == mode);
    }
    loginMode ??= LoginMode.Manual;
    if (loginModeNotifier.value != loginMode) {
      loginModeNotifier.value = loginMode;
    }
  }

  @override
  List<Pattern> get pathPatterns => [
        "/",
        "/login",
        "/home",
        "/screens/:$screenNameKey",
        "/settings",
      ];
}
