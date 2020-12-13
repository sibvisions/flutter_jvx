import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/models/api/response.dart';
import 'package:jvx_flutterclient/core/ui/component/component_widget.dart';

import '../../../../core/ui/screen/so_component_creator.dart';
import '../../../../core/ui/screen/so_screen.dart';
import '../../../../core/ui/screen/so_screen_configuration.dart';
import '../../../../core/utils/app/listener/application_api.dart';
import '../../../../core/utils/app/listener/data_api.dart';

class CustomScreen extends SoScreen {
  final SoScreenConfiguration configuration;
  final String templateName;

  const CustomScreen(
      {Key key,
      this.templateName,
      SoComponentCreator creator,
      this.configuration})
      : super(
            key: key,
            configuration: configuration,
            creator: creator,
            templateName: templateName);

  @override
  SoScreenState<StatefulWidget> createState() => CustomScreenState();
}

class CustomScreenState extends SoScreenState<CustomScreen> {
  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }

  @override
  void update(Response response) {
    super.update(response);
  }

  @override
  void onResponse(Response response) {
    super.onResponse(response);
  }

  DataApi getDataApi(BuildContext context, String dataProvider) {
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

  /// Method for replacing components in widget tree by name.
  ///
  /// Returns `true` if component could be replaced.
  ///
  /// Returns `false` if component could not be replaced.
  bool replaceComponentByName(String name, ComponentWidget newComponentWidget) {
    ComponentWidget toReplaceComponent = this
        .components
        .values
        .toList()
        .firstWhere((component) => component.componentModel.name == name,
            orElse: () => null);

    if (toReplaceComponent != null) {
      this.replaceComponent(newComponentWidget, toReplaceComponent);
      return true;
    }
    return false;
  }

  String getTemplateName() => widget.templateName;
}
