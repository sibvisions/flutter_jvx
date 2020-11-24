import 'package:flutter/material.dart';

import '../../models/api/response.dart';
import 'component_screen_widget.dart';
import 'i_screen.dart';
import 'so_component_creator.dart';

class SoScreen implements IScreen {
  String componentId;
  Response response;
  bool closeCurrentScreen;
  SoComponentCreator componentCreator;
  GlobalKey<ComponentScreenWidgetState> screenKey;

  SoScreen(
      {Key key,
      this.componentId,
      this.response,
      this.closeCurrentScreen,
      this.componentCreator,
      this.screenKey});

  @override
  Widget getWidget(BuildContext context) {
    return FractionallySizedBox(
        widthFactor: 1,
        heightFactor: 1,
        child: ComponentScreenWidget(
          key: this.screenKey,
          closeCurrentScreen: this.closeCurrentScreen,
          componentCreator: this.componentCreator,
          response: this.response,
        ));
  }

  @override
  bool withServer() {
    return true;
  }

  @override
  void update(Response response) {
    this.response = response;
  }

  void setCloseCurrentScreen(bool closeCurrentScreen) {
    this.closeCurrentScreen = closeCurrentScreen;
  }
}
