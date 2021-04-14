import 'package:flutter/material.dart';

import '../../../injection_container.dart';
import '../../models/state/app_state.dart';
import '../../services/local/shared_preferences/shared_preferences_manager.dart';
import '../../util/theme/theme_manager.dart';
import '../widgets/page/startup/startup_page_widget.dart';
import '../widgets/page/startup/offline_startup_page_widget.dart';

class StartupPage extends StatelessWidget {
  final Widget? startupWidget;
  final AppState appState;
  final SharedPreferencesManager manager;

  const StartupPage(
      {Key? key,
      this.startupWidget,
      required this.appState,
      required this.manager})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (startupWidget != null) {
      return startupWidget!;
    }
    return Theme(
        data: sl<ThemeManager>().value,
        child: _getStartupPageWidget(appState.isOffline));
  }

  Widget _getStartupPageWidget(bool isOffline) {
    if (isOffline) {
      return OfflineStartupPageWidget(
        appState: appState,
        manager: manager,
        startupWidget: startupWidget,
      );
    } else {
      return StartupPageWidget(
        appState: appState,
        manager: manager,
        startupWidget: startupWidget,
      );
    }
  }
}
