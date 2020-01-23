import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/model/api/response/menu.dart';

import '../../model/api/request/request.dart';
import '../../model/api/response/data/jvx_data.dart';
import '../../model/api/response/meta_data/jvx_meta_data.dart';
import '../../model/api/response/screen_generic.dart';
import '../../ui/screen/component_creator.dart';
import '../../ui/screen/component_screen.dart';
import '../../ui/screen/i_screen.dart';
import '../first_custom_screen.dart';
import 'custom_screen.dart'; 

class FirstCustomScreen extends CustomScreen implements IScreen {
  @override
  ComponentScreen componentScreen;

  FirstCustomScreen(ComponentCreator componentCreator) : componentScreen = ComponentScreen(componentCreator);

  @override
  Widget getWidget() {
    return Center(
      child: FirstCustomScreenWidget(),
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
