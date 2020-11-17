import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/ui/component/component_widget.dart';

import '../../../../core/models/api/response.dart';
import '../../../../core/ui/screen/component_screen_widget.dart';
import '../../../../core/ui/screen/i_screen.dart';
import '../../../../core/ui/screen/so_component_creator.dart';
import '../../../../core/utils/app/listener/application_api.dart';
import '../../../../core/utils/app/listener/data_api.dart';

/// Implementation of [IScreen] for custom screens.
class CustomScreen extends StatelessWidget implements IScreen {
  final String componentId;
  final String _templateName;
  final Response currentResponse = Response();
  final CustomHeaderAndFooter customHeaderAndFooter = CustomHeaderAndFooter();

  CustomScreen(this.componentId, this._templateName);

  @override
  void update(Response response) {
    this.currentResponse.copyFrom(response);
  }

  @override
  bool withServer() {
    return true;
  }

  DataApi getDataApi(String dataProvider) {
    // return DataApi(componentScreen.getComponentData(dataProvider),
    //     componentScreen.context);
  }

  ApplicationApi getApplicationApi(BuildContext context) {
    return ApplicationApi(context);
  }

  void setHeader(ComponentWidget headerComponent) {
    customHeaderAndFooter.headerComponent = headerComponent;
  }

  void setFooter(ComponentWidget footerComponent) {
    customHeaderAndFooter.footerComponent = footerComponent;
  }

  String getTemplateName() {
    return _templateName;
  }

  @override
  Widget build(BuildContext context) {
    // If you want to use the Layout Components from us you need to return a ComponentScreenWidget.
    // This widget handles all rendering, layouting and data.
    // You can wrap it with whatever you like but it has to be in the widget tree.
    return ComponentScreenWidget(
      response: this.currentResponse,
      closeCurrentScreen: false,
      componentCreator: SoComponentCreator(),
    );
  }

  @override
  set componentId(String _componentId) {}
}

class CustomHeaderAndFooter {
  ComponentWidget headerComponent;
  ComponentWidget footerComponent;

  CustomHeaderAndFooter();
}
