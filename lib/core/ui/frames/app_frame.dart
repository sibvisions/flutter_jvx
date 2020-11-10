import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../injection_container.dart';
import '../../models/app/app_state.dart';
import '../widgets/util/app_state_provider.dart';
import 'i_app_frame.dart';
import 'web_frame.dart';

class AppFrame extends IAppFrame {
  AppFrame(BuildContext context) : super(context);

  @override
  Widget getMobileFrameWidget() {
    if (screen != null) {
      return screen;
    }
    return menu;
  }

  @override
  Widget getWebFrameWidget() {
    return WebFrame(menu: menu, screen: screen);
  }

  bool get showScreenHeader {
    AppState appState = sl<AppState>();

    if (appState.webOnly &&
        !appState.mobileOnly &&
        appState.layoutMode == 'Full') {
      return false;
    } else if (appState.mobileOnly && !appState.webOnly) {
      return true;
    } else {
      if (kIsWeb && appState.layoutMode == 'Full') {
        return false;
      } else {
        return true;
      }
    }
  }
}
