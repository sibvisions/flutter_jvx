import 'package:flutter/material.dart';
import '../utils/globals.dart' as globals;
import 'package:flutter/foundation.dart' show kIsWeb;

abstract class IAppFrame {
  Widget menu;
  Widget screen;
  BuildContext context;
  bool forceWeb = false;

  IAppFrame(BuildContext context) {
    this.context = context;
  }

  Widget getWidget() {
    if ((kIsWeb || forceWeb) &&
        globals.layoutMode == 'Full' &&
        !globals.mobileOnly) {
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

  bool get showScreenHeader {
    if ((kIsWeb || forceWeb) &&
        globals.layoutMode == 'Full' &&
        !globals.mobileOnly) {
      return false;
    }
    return true;
  }

  void setForceWeb(bool forceWeb) {
    this.forceWeb = forceWeb;
  }
}
