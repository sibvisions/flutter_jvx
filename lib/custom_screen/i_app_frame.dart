import 'package:flutter/material.dart';
import '../utils/globals.dart' as globals;
import 'package:flutter/foundation.dart' show kIsWeb;

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

  void setScreen(screen) {
    this.screen = screen;
  }

  void setWebOnly(bool webOnly) {
    globals.webOnly = webOnly;
  }

  void setMobileOnly(bool mobileOnly) {
    globals.mobileOnly = mobileOnly;
  }

  bool get isWeb {
    if (globals.webOnly && !globals.mobileOnly) {
      return true;
    } else if (globals.mobileOnly && !globals.webOnly) {
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
