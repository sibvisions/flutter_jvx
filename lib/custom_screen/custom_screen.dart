import 'package:flutter/material.dart';
import '../ui/screen/component_creator.dart';
import '../ui/screen/i_screen.dart';

import '../model/api/request/request.dart';
import '../model/api/response/data/jvx_data.dart';
import '../model/api/response/meta_data/jvx_meta_data.dart';
import '../model/api/response/screen_generic.dart';
import '../ui/screen/component_screen.dart';

/// Implementation of [IScreen] for custom screens.
class CustomScreen implements IScreen {

  CustomScreen(ComponentCreator componentCreator) : componentScreen = ComponentScreen(componentCreator);

  @override
  ComponentScreen componentScreen;

  @override
  Widget getWidget() {
    return Container();
  }

  @override
  void update(Request request, List<JVxData> data, List<JVxMetaData> metaData, ScreenGeneric genericScreen) {}

  @override
  bool withServer() {
    return true;
  }
}