import 'package:flutter/material.dart';

import '../../../../core/models/api/response.dart';
import '../../../../core/ui/component/component_widget.dart';
import '../../../../core/ui/screen/component_screen_widget.dart';
import '../../../../core/ui/screen/i_screen.dart';
import '../../../../core/ui/screen/so_component_creator.dart';
import '../../../../core/ui/screen/so_component_data.dart';
import '../../../../core/utils/app/listener/application_api.dart';
import '../../../../core/utils/app/listener/data_api.dart';

/// Implementation of [IScreen] for custom screens.
class CustomScreen extends StatelessWidget implements IScreen {
  final String componentId;
  final String _templateName;
  final Response currentResponse = Response();
  final CustomHeaderAndFooter customHeaderAndFooter = CustomHeaderAndFooter();
  final List<SoComponentData> componentData = <SoComponentData>[];
  final Map<String, ComponentWidget> toReplace = <String, ComponentWidget>{};
  final SoComponentCreator componentCreator;

  CustomScreen(this.componentId, this._templateName, this.componentCreator, {Key key}) : super(key: key);

  @override
  void update(Response response) {
    this.currentResponse.copyFrom(response);
  }

  getComponentData(String dataProvider) {
    SoComponentData data;
    if (componentData.length > 0)
      data = componentData.firstWhere((d) => d.dataProvider == dataProvider,
          orElse: () => null);

    return data;
  }

  @override
  bool withServer() {
    return true;
  }

  DataApi getDataApi(String dataProvider, BuildContext context) {
    return DataApi(getComponentData(dataProvider), context);
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

  void replaceComponent(String name, ComponentWidget toReplaceComponent) {
    if (!this.toReplace.containsKey(name)) {
      this.toReplace[name] = toReplaceComponent;
    }
  }

  String getTemplateName() {
    return _templateName;
  }

  @override
  Widget build(BuildContext context) {
    // If you want to use the Layout Components from us you need to return a ComponentScreenWidget.
    // This widget handles all rendering, layouting and data.
    // You can wrap it with whatever you like but it has to be in the widget tree.
    return FractionallySizedBox(
      widthFactor: 1,
      heightFactor: 1,
      child: ComponentScreenWidget(
        response: this.currentResponse,
        closeCurrentScreen: false,
        componentCreator: this.componentCreator,
        footerComponent: customHeaderAndFooter.footerComponent,
        headerComponent: customHeaderAndFooter.headerComponent,
        onData: (List<SoComponentData> data) {
          this.componentData.clear();
          this.componentData.addAll(data);
        },
        toReplace: this.toReplace,
      ),
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
