import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/custom_screen/web_frame.dart';
import '../utils/globals.dart' as globals;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'i_app_frame.dart';

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

  bool get isWeb {
    if (globals.webOnly &&
        !globals.mobileOnly &&
        globals.layoutMode == 'Full') {
      return true;
    } else if (globals.mobileOnly && !globals.webOnly) {
      return false;
    } else {
      if (kIsWeb && globals.layoutMode == 'Full') {
        return true;
      } else {
        return false;
      }
    }
  }
}
