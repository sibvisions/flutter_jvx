
import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/custom_screen/web_frame.dart';


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
}
