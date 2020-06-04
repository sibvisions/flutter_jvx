import 'package:flutter/material.dart';
import '../model/api/response/response_data.dart';
import '../ui/screen/component_creator.dart';
import '../ui/screen/i_screen.dart';
import '../model/api/request/request.dart';
import '../ui/screen/component_screen.dart';

/// Implementation of [IScreen] for custom screens.
class CustomScreen implements IScreen {
  CustomScreen(ComponentCreator componentCreator)
      : componentScreen = ComponentScreen(componentCreator);

  @override
  ComponentScreen componentScreen;

  @override
  Widget getWidget() {
    return Container();
  }

  @override
  void update(Request request, ResponseData data) {
    componentScreen.updateData(request, data);
    if (data.screenGeneric != null)
      componentScreen.updateComponents(data.screenGeneric.changedComponents);
  }

  @override
  bool withServer() {
    return true;
  }
}
