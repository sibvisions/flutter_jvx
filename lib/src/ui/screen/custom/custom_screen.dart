import 'package:flutter/material.dart';

import '../../../services/remote/cubit/api_cubit.dart';
import '../../../util/app/listener/application_api.dart';
import '../../component/component_widget.dart';
import '../core/configuration/so_screen_configuration.dart';
import '../core/so_component_creator.dart';
import '../core/so_screen.dart';

class CustomScreen extends SoScreen {
  CustomScreen({
    Key? key,
    required SoScreenConfiguration configuration,
    required SoComponentCreator creator,
  }) : super(
          key: key,
          configuration: configuration,
          creator: creator,
        );
}

class CustomScreenState extends SoScreenState<CustomScreen> {
  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }

  @override
  void onState(ApiState? state) {
    super.onState(state);
  }

  // DataApi getDataApi(BuildContext context, String dataProvider) {
  //   return DataApi(this.getComponentData(dataProvider), context);
  // }

  ApplicationApi getApplicationApi(BuildContext context) {
    return ApplicationApi(context);
  }

  void setHeader(ComponentWidget header) {
    this.header = header;
  }

  void setFooter(ComponentWidget footer) {
    this.footer = footer;
  }

  @override
  AppBar getDefaultAppBar() {
    return super.getDefaultAppBar();
  }

  /// Method for replacing components in widget tree by name.
  ///
  /// Returns `true` if component could be replaced.
  ///
  /// Returns `false` if component could not be replaced.
  bool replaceComponentByName(String name, ComponentWidget newComponentWidget) {
    ComponentWidget? toReplaceComponent;

    try {
      toReplaceComponent = components.values
          .toList()
          .firstWhere((component) => component.componentModel.name == name);
    } catch (e) {
      return false;
    }

    replaceComponent(newComponentWidget, toReplaceComponent);
    return true;
  }

  String? getTemplateName() => widget.configuration.templateName;
}
