import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/model/changed_component.dart';
import 'package:jvx_flutterclient/model/properties/component_properties.dart';
import 'package:jvx_flutterclient/ui/layout/co_border_layout.dart';
import 'package:jvx_flutterclient/ui/layout/co_flow_layout.dart';
import 'package:jvx_flutterclient/ui/layout/co_form_layout.dart';
import 'package:jvx_flutterclient/ui/layout/co_grid_layout.dart';
import 'package:jvx_flutterclient/ui/layout/co_layout.dart';
import 'package:jvx_flutterclient/ui/layout/widgets/co_border_layout_constraint.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_model.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_widget.dart';

import '../../jvx_flutterclient.dart';

class CoContainerWidget extends ComponentWidget {
  CoContainerWidget({Key key, ComponentModel componentModel})
      : super(key: key, componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoContainerWidgetState();
}

class CoContainerWidgetState extends ComponentWidgetState<CoContainerWidget> {
  CoLayout layout;
  List<ComponentWidget> components = new List<ComponentWidget>();

  void add(ComponentWidget pComponent) {
    addWithContraintsAndIndex(pComponent, null, -1);
  }

  void addWithConstraints(ComponentWidget pComponent, String pConstraints) {
    addWithContraintsAndIndex(pComponent, pConstraints, -1);
  }

  void addWithIndex(ComponentWidget pComponent, int pIndex) {
    addWithContraintsAndIndex(pComponent, null, pIndex);
  }

  void addWithContraintsAndIndex(
      ComponentWidget pComponent, String pConstraints, int pIndex) {
    if (pIndex < 0) {
      components.add(pComponent);
    } else {
      components.insert(pIndex, pComponent);
    }

    pComponent.componentModel.componentState.state = CoState.Added;

    if (layout != null) {
      if (layout is CoBorderLayout) {
        CoBorderLayoutConstraints contraints =
            getBorderLayoutConstraintsFromString(pConstraints);
        layout.addLayoutComponent(pComponent, contraints);
      } else if (layout is CoFormLayout) {
        layout.addLayoutComponent(pComponent, pConstraints);
      } else if (layout is CoFlowLayout) {
        layout.addLayoutComponent(pComponent, pConstraints);
      } else if (layout is CoGridLayout) {
        layout.addLayoutComponent(pComponent, pConstraints);
      }
    }
  }

  void remove(int pIndex) {
    ComponentWidget pComponent = components[pIndex];
    if (layout != null) {
      layout.removeLayoutComponent(pComponent);
    }
    components.removeAt(pIndex);
  }

  void removeWithComponent(ComponentWidget pComponent) {
    int index = components.indexWhere((c) =>
        c.componentModel.componentState.componentId.toString() ==
        pComponent.componentModel.componentId.toString());

    if (index >= 0) {
      remove(index);
      pComponent.componentModel.componentState.state = CoState.Free;
    }
  }

  void removeAll() {
    while (components.length > 0) {
      remove(components.length - 1);
    }
  }

  ComponentWidget getComponentWithContraint(String constraint) {
    return components?.firstWhere((component) =>
        component.componentModel.componentState.constraints == constraint);
  }

  void updateComponentProperties(
      Key componentId, ChangedComponent changedComponent) {
    ComponentWidget pComponent = components.firstWhere(
        (c) => c.componentModel.componentState.componentId == componentId);

    pComponent.componentModel.changedComponent = changedComponent;

    preferredSize = changedComponent.getProperty<Size>(
        ComponentProperty.PREFERRED_SIZE, null);
    maximumSize = changedComponent.getProperty<Size>(
        ComponentProperty.MAXIMUM_SIZE, null);

    if (layout != null) {
      if (layout is CoBorderLayout) {
        CoBorderLayoutConstraints contraints =
            layout.getConstraints(pComponent);
        (layout as CoBorderLayout).addLayoutComponent(pComponent, contraints);
      }
    }
  }
}
