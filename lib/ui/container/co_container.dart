import 'package:flutter/material.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import '../component/i_component.dart';
import '../component/component.dart';
import 'i_container.dart';
import '../layout/co_border_layout.dart';
import '../layout/co_flow_layout.dart';
import '../layout/co_form_layout.dart';
import '../layout/co_grid_layout.dart';
import '../layout/co_layout.dart';
import '../layout/widgets/co_border_layout_constraint.dart';

abstract class CoContainer extends Component implements IContainer {
  CoLayout layout;
  List<IComponent> components = new List<IComponent>();

  CoContainer(GlobalKey componentId, BuildContext context)
      : super(componentId, context);

  void add(IComponent pComponent) {
    addWithContraintsAndIndex(pComponent, null, -1);
  }

  void addWithConstraints(IComponent pComponent, String pConstraints) {
    addWithContraintsAndIndex(pComponent, pConstraints, -1);
  }

  void addWithIndex(IComponent pComponent, int pIndex) {
    addWithContraintsAndIndex(pComponent, null, pIndex);
  }

  void addWithContraintsAndIndex(
      IComponent pComponent, String pConstraints, int pIndex) {
    if (pIndex < 0) {
      components.add(pComponent);
    } else {
      components.insert(pIndex, pComponent);
    }

    pComponent.state = CoState.Added;

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
    IComponent pComponent = components[pIndex];
    if (layout != null) {
      layout.removeLayoutComponent(pComponent);
    }
    components.removeAt(pIndex);
  }

  void removeWithComponent(IComponent pComponent) {
    int index = components.indexWhere(
        (c) => c.componentId.toString() == pComponent.componentId.toString());

    if (index >= 0) {
      remove(index);
      pComponent.state = CoState.Free;
    }
  }

  void removeAll() {
    while (components.length > 0) {
      remove(components.length - 1);
    }
  }

  Component getComponentWithContraint(String constraint) {
    return components
        ?.firstWhere((component) => component.constraints == constraint);
  }

  void updateComponentProperties(
      Key componentId, ChangedComponent changedComponent) {
    IComponent pComponent =
        components.firstWhere((c) => c.componentId == componentId);

    pComponent?.updateProperties(changedComponent);

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
