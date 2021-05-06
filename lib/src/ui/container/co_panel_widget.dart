import 'package:flutter/material.dart';

import '../component/component_widget.dart';
import 'co_container_widget.dart';
import 'models/container_component_model.dart';

class CoPanelWidget extends CoContainerWidget {
  CoPanelWidget({required ContainerComponentModel componentModel})
      : super(componentModel: componentModel);

  State<StatefulWidget> createState() => CoPanelWidgetState();
}

class CoPanelWidgetState extends CoContainerWidgetState {
  List<Widget> _getNullLayout(List<ComponentWidget> components) {
    List<Widget> children = <Widget>[];

    components.forEach((element) {
      if (element.componentModel.isVisible) {
        children.add(element);
      }
    });

    return children;
  }

  @override
  Widget build(BuildContext context) {
    ContainerComponentModel componentModel =
        widget.componentModel as ContainerComponentModel;

    late Widget child;

    if (componentModel.layout != null) {
      child = componentModel.layout as Widget;
      if (componentModel.layout!.setState != null) {
        componentModel.layout!.setState!(() {});
      }
    } else if (componentModel.components.isNotEmpty) {
      child = Column(children: _getNullLayout(componentModel.components));
    } else {
      child = Container();
    }

    return Container(
      color: widget.componentModel.background,
      child: child,
    );
  }
}
