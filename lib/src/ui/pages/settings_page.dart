import 'package:flutter/material.dart';

import '../../../injection_container.dart';
import '../../models/state/app_state.dart';
import '../../services/local/shared_preferences/shared_preferences_manager.dart';
import '../../util/theme/theme_manager.dart';
import '../util/inherited_widgets/app_state_provider.dart';
import '../util/inherited_widgets/shared_preferences_provider.dart';
import '../widgets/page/settings/settings_page_widget.dart';

class SettingsPage extends StatelessWidget {
  final bool canPop;
  final bool hasError;

  const SettingsPage({Key? key, required this.canPop, this.hasError = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppState appState = AppStateProvider.of(context)!.appState;
    SharedPreferencesManager manager =
        SharedPreferencesProvider.of(context)!.manager;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Theme(
          data: sl<ThemeManager>().value,
          child: SettingsPageWidget(
            appState: appState,
            manager: manager,
            canPop: canPop,
          )),
    );
  }
}
