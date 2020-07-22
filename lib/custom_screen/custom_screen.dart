import 'package:flutter/material.dart';
import '../ui/component/i_component.dart';
import '../model/api/response/response_data.dart';
import '../ui/screen/so_component_creator.dart';
import '../ui/screen/i_screen.dart';
import '../model/api/request/request.dart';
import '../ui/screen/so_component_screen.dart';

/// Implementation of [IScreen] for custom screens.
class CustomScreen implements IScreen {
  CustomScreen(SoComponentCreator componentCreator)
      : componentScreen = SoComponentScreen(componentCreator);

  @override
  SoComponentScreen componentScreen;

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

  void setHeader(IComponent headerComponent) {
    componentScreen.setHeader(headerComponent);
  }

  void setFooter(IComponent footerComponent) {
    componentScreen.setHeader(footerComponent);
  }
}
