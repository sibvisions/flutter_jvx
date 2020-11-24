import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/models/api/response.dart';
import 'package:jvx_flutterclient/core/ui/component/component_widget.dart';
import 'package:jvx_flutterclient/core/ui/screen/component_screen_widget.dart';
import 'package:jvx_flutterclient/core/ui/screen/i_screen.dart';
import 'package:jvx_flutterclient/core/ui/screen/so_component_creator.dart';
import 'package:jvx_flutterclient/core/ui/screen/so_component_data.dart';
import 'package:jvx_flutterclient/core/utils/app/listener/application_api.dart';
import 'package:jvx_flutterclient/core/utils/app/listener/data_api.dart';

class CustomScreen implements IScreen {
  @override
  String componentId;

  String _templateName;
  Response currentResponse;

  ComponentWidget header;
  ComponentWidget footer;

  List<SoComponentData> data = <SoComponentData>[];

  Map<String, ComponentWidget> toReplace = <String, ComponentWidget>{};

  SoComponentCreator creator;

  Widget widget;

  GlobalKey<ComponentScreenWidgetState> screenKey;

  CustomScreen(this._templateName, {this.componentId, this.creator, this.screenKey});

  @override
  void update(Response response) {
    this.currentResponse = response;
  }

  @override
  bool withServer() => true;

  @override
  Widget getWidget(BuildContext context) {
    // If you want to use the Layout Components from us you need to return a ComponentScreenWidget.
    // This widget handles all rendering, layouting and data.
    // You can wrap it with whatever you like but it has to be in the widget tree.
    if (widget != null) {
      return widget;
    }
    return FractionallySizedBox(
      widthFactor: 1,
      heightFactor: 1,
      child: ComponentScreenWidget(
        key: this.screenKey,
        response: this.currentResponse,
        closeCurrentScreen: false,
        componentCreator: this.creator,
        footerComponent: this.footer,
        headerComponent: this.header,
        onData: (List<SoComponentData> data) {
          this.data = data;
        },
        toReplace: this.toReplace,
      ),
    );
  }

  SoComponentData getComponentData(String dataProvider) {
    SoComponentData data;

    if (this.data.length > 0)
      data = this.data.firstWhere((d) => d.dataProvider == dataProvider,
          orElse: () => null);

    return data;
  }

  DataApi getDataApi(String dataProvider, BuildContext context) {
    return DataApi(this.getComponentData(dataProvider), context);
  }

  ApplicationApi getApplicationApi(BuildContext context) {
    return ApplicationApi(context);
  }

  void setHeader(ComponentWidget header) {
    this.header = header;
  }

  void setFooter(ComponentWidget footer) {
    this.footer = footer;
  }

  void replaceComponent(String name, ComponentWidget toReplaceComponent) {
    if (!this.toReplace.containsKey(name)) {
      this.toReplace[name] = toReplaceComponent;
    }
  }

  String getTemplateName() => _templateName;
}
