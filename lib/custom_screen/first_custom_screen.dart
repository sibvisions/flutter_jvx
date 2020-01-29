import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/model/menu_item.dart';
import 'package:jvx_mobile_v3/ui/screen/i_screen.dart';

import '../model/api/request/request.dart';
import '../model/api/response/data/jvx_data.dart';
import '../model/api/response/meta_data/jvx_meta_data.dart';
import '../model/api/response/screen_generic.dart';
import '../ui/screen/component_creator.dart';
import 'custom_screen.dart'; 

class FirstCustomScreen extends CustomScreen {
  FirstCustomScreen(ComponentCreator componentCreator) : super(componentCreator);

  @override
  Widget getWidget() {
    return Center(
      child: Container(),
    );
  }

  @override
  void update(Request request, List<JVxData> data, List<JVxMetaData> metaData,
      ScreenGeneric genericScreen) {
    // Just testing
  }

  @override
  List<MenuItem> onMenu(List<MenuItem> menu) {
    return menu;
  }

  @override
  IScreen getScreen(String componentId) {
    // TODO: implement getScreen
    return null;
  }
}
