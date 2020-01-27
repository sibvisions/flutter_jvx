import 'package:flutter/material.dart';

import '../model/api/request/request.dart';
import '../model/api/response/data/jvx_data.dart';
import '../model/api/response/menu.dart';
import '../model/api/response/meta_data/jvx_meta_data.dart';
import '../model/api/response/screen_generic.dart';
import '../ui/screen/component_creator.dart';
import '../ui/screen/component_screen.dart';
import 'custom_screen.dart'; 

class FirstCustomScreen extends CustomScreen {
  @override
  ComponentScreen componentScreen;

  FirstCustomScreen(ComponentCreator componentCreator) : componentScreen = ComponentScreen(componentCreator);

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
  shouldShowCustomScreen() {
    return true;
  }

  @override
  onMenu(Menu menu) {
    
  }
}
