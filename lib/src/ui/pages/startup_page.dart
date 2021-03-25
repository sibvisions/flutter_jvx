import 'package:flutter/material.dart';
import 'package:flutterclient/injection_container.dart';
import 'package:flutterclient/src/models/state/app_state.dart';
import 'package:flutterclient/src/services/local/shared_preferences/shared_preferences_manager.dart';
import 'package:flutterclient/src/ui/widgets/page/startup_page_widget.dart';
import 'package:flutterclient/src/util/theme/theme_manager.dart';

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
        child: StartupPageWidget(
          appState: appState,
          manager: manager,
          startupWidget: startupWidget,
        ));
  }
}
