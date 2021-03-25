import 'package:flutter/material.dart';

import '../../../injection_container.dart';
import '../../models/state/app_state.dart';
import '../../services/local/shared_preferences/shared_preferences_manager.dart';
import '../../services/remote/cubit/api_cubit.dart';
import '../../util/theme/theme_manager.dart';
import '../widgets/page/open_screen/open_screen_page_widget.dart';

class OpenScreenPage extends StatelessWidget {
  final AppState appState;
  final SharedPreferencesManager manager;
  final ApiResponse response;

  const OpenScreenPage(
      {Key? key,
      required this.appState,
      required this.manager,
      required this.response})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: sl<ThemeManager>().value,
        child: OpenScreenPageWidget(
          appState: appState,
          manager: manager,
          response: response,
        ));
  }
}
