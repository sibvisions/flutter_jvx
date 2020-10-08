import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/model/changed_component.dart';
import 'package:jvx_flutterclient/model/properties/component_properties.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_model.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/container/container_component_model.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/co_border_layout.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/co_layout.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/widgets/co_border_layout_constraint.dart';

import '../../jvx_flutterclient.dart';

class CoContainerWidget extends ComponentWidget {
  CoContainerWidget({Key key, ComponentModel componentModel})
      : super(key: key, componentModel: componentModel);

  static CoContainerWidgetState of(BuildContext context) =>
      context.findAncestorStateOfType<CoContainerWidgetState>();

  @override
  State<StatefulWidget> createState() => CoContainerWidgetState();
}

class CoContainerWidgetState extends ComponentWidgetState<CoContainerWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }

  void updateComponentProperties(
      String componentId, ChangedComponent changedComponent) {
    preferredSize = changedComponent.getProperty<Size>(
        ComponentProperty.PREFERRED_SIZE, null);
    maximumSize = changedComponent.getProperty<Size>(
        ComponentProperty.MAXIMUM_SIZE, null);
  }
}
