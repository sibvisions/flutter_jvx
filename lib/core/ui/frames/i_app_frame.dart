import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../injection_container.dart';
import '../../models/app/app_state.dart';
import '../widgets/util/app_state_provider.dart';

abstract class IAppFrame {
  Widget menu;
  Widget screen;
  BuildContext context;

  IAppFrame(BuildContext context) {
    this.context = context;
  }

  Widget getWidget() {
    if (isWeb) {
      return getWebFrameWidget();
    } else {
      return getMobileFrameWidget();
    }
  }

  Widget getMobileFrameWidget();

  Widget getWebFrameWidget();

  void setMenu(Widget menu) {
    this.menu = menu;
  }

  void setScreen(Widget screen) {
    this.screen = screen;
  }

  void setWebOnly(bool webOnly) {
    AppStateProvider.of(context).appState.webOnly = webOnly;
  }

  void setMobileOnly(bool mobileOnly) {
    AppStateProvider.of(context).appState.mobileOnly = mobileOnly;
  }

  bool get isWeb {
    AppState appState = sl<AppState>();

    if (appState.webOnly && !appState.mobileOnly) {
      return true;
    } else if (appState.mobileOnly && !appState.webOnly) {
      return false;
    } else {
      if (kIsWeb) {
        return true;
      } else {
        return false;
      }
    }
  }

  bool get showScreenHeader {
    return !isWeb;
  }
}
