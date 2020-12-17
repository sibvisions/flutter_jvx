import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/ui/layout/co_border_layout_container_widget.dart';
import 'package:jvx_flutterclient/core/ui/layout/widgets/co_border_layout_constraint.dart';

import '../component/component_widget.dart';
import 'container_component_model.dart';

class CoContainerWidget extends ComponentWidget {
  ContainerComponentModel componentModel;
  CoContainerWidget({this.componentModel})
      : super(componentModel: componentModel);

  static CoContainerWidgetState of(BuildContext context) =>
      context.findAncestorStateOfType<CoContainerWidgetState>();

  @override
  State<StatefulWidget> createState() => CoContainerWidgetState();
}

class CoContainerWidgetState extends ComponentWidgetState<CoContainerWidget> {
  @override
  void didUpdateWidget(CoContainerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    ContainerComponentModel componentModel = widget.componentModel;

    if (componentModel.changedComponent != null) {
      componentModel.layout = componentModel.createLayout(
          widget, widget.componentModel.changedComponent);
    }

    if (widget.componentModel.componentId == 'headerFooterPanel') {
      componentModel.layout = componentModel.createLayoutForHeaderFooterPanel(
          widget, 'BorderLayout,0,0,0,0,0,0,');
    }

    componentModel.components.forEach((component) {
      if (componentModel.layout is CoBorderLayoutContainerWidget) {
        CoBorderLayoutConstraints contraints =
            getBorderLayoutConstraintsFromString(
                component.componentModel.constraints);

        componentModel.layout.addLayoutComponent(component, contraints);
      } else {
        componentModel.layout.addLayoutComponent(
            component, component.componentModel.constraints);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    ContainerComponentModel componentModel = widget.componentModel;

    if (componentModel.changedComponent != null) {
      componentModel.layout = componentModel.createLayout(
          widget, widget.componentModel.changedComponent);
    }

    if (widget.componentModel.componentId == 'headerFooterPanel') {
      componentModel.layout = componentModel.createLayoutForHeaderFooterPanel(
          widget, 'BorderLayout,0,0,0,0,0,0,');
    }

    componentModel.components.forEach((component) {
      if (componentModel.layout is CoBorderLayoutContainerWidget) {
        CoBorderLayoutConstraints contraints =
            getBorderLayoutConstraintsFromString(
                component.componentModel.constraints);

        componentModel.layout.addLayoutComponent(component, contraints);
      } else {
        componentModel.layout?.addLayoutComponent(
            component, component.componentModel.constraints);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }
}
