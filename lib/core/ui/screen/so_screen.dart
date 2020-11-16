import 'package:flutter/material.dart';

import '../../models/api/response.dart';
import 'component_screen_widget.dart';
import 'i_screen.dart';
import 'so_component_creator.dart';

class SoScreen extends StatelessWidget implements IScreen {
  final String componentId;
  final Response response;
  final bool closeCurrentScreen;
  final SoComponentCreator componentCreator;
  final GlobalKey<ComponentScreenWidgetState> screenKey;

  const SoScreen(
      {Key key,
      this.componentId,
      this.response,
      this.closeCurrentScreen,
      this.componentCreator,
      this.screenKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
    this.response.request = response.request;
    this.response.responseData = response.responseData;
  }

  @override
  set componentId(String _componentId) {
    
  }
}
