import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/models/api/response.dart';
import 'package:jvx_flutterclient/core/ui/screen/component_screen_widget.dart';
import 'package:jvx_flutterclient/core/ui/screen/so_component_creator.dart';

import '../../models/api/request.dart';
import '../../models/api/response/response_data.dart';
import 'i_screen.dart';

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
}
