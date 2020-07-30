import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

abstract class IAppFrame {
  Widget menu;
  Widget screen;
  BuildContext context;

  IAppFrame(BuildContext context) {
    this.context = context;
  }

  Widget getWidget() {
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    if (deviceType == DeviceScreenType.desktop) {
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
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    if (deviceType == DeviceScreenType.desktop) {
      return false;
    }
    return true;
  }
}
