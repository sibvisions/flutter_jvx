import 'package:flutter/material.dart';

import '../../../../core/ui/screen/so_component_creator.dart';
import '../../../../core/ui/screen/so_screen.dart';
import '../../../../core/ui/screen/so_screen_configuration.dart';
import '../../../../core/utils/app/listener/application_api.dart';
import '../../../../core/utils/app/listener/data_api.dart';

class CustomScreen extends SoScreen {
  final SoScreenConfiguration configuration;
  final String templateName;

  CustomScreen({this.templateName, SoComponentCreator creator, this.configuration}) : super(configuration: configuration, creator: creator);
}

class CustomScreenState extends SoScreenState<CustomScreen> {
  DataApi getDataApi(String dataProvider, BuildContext context) {
    return DataApi(this.getComponentData(dataProvider), context);
  }

  ApplicationApi getApplicationApi(BuildContext context) {
    return ApplicationApi(context);
  }

  // void setHeader(ComponentWidget header) {
  //   this.header = header;
  // }

  // void setFooter(ComponentWidget footer) {
  //   this.footer = footer;
  // }

  // void replaceComponent(String name, ComponentWidget toReplaceComponent) {
  //   if (!this.toReplace.containsKey(name)) {
  //     this.toReplace[name] = toReplaceComponent;
  //   }
  // }

  String getTemplateName() => widget.templateName;
}
