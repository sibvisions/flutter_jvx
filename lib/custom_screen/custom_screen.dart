import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/model/menu_item.dart';

import '../model/api/request/request.dart';
import '../model/api/response/data/jvx_data.dart';
import '../model/api/response/meta_data/jvx_meta_data.dart';
import '../model/api/response/screen_generic.dart';
import '../ui/screen/component_screen.dart';
import 'i_custom_screen.dart';

class CustomScreen implements ICustomScreen {
  @override
  shouldShowCustomScreen() {
    return false;
  }

  @override
  onMenu(List<MenuItem> menu) {
    return null;
  }

  @override
  ComponentScreen componentScreen;

  @override
  Widget getWidget() {
    // TODO: implement getWidget
    return null;
  }

  @override
  void update(Request request, List<JVxData> data, List<JVxMetaData> metaData, ScreenGeneric genericScreen) {
    // TODO: implement update
  }
}