import 'package:flutter/material.dart';

import '../../models/api/component/changed_component.dart';
import '../../models/api/component/component_properties.dart';
import '../component/component_widget.dart';
import '../component/models/component_model.dart';
import '../layout/co_border_layout_container_widget.dart';
import '../layout/co_flow_layout_container_widget.dart';
import '../layout/co_form_layout_container_widget.dart';
import '../layout/co_grid_layout_container_widget.dart';
import '../layout/co_layout.dart';
import '../layout/i_layout.dart';
import '../layout/widgets/co_border_layout_constraint.dart';
import '../screen/so_screen.dart';
import 'co_container_widget.dart';

class ContainerComponentModel extends ComponentModel {
  CoLayout layout;
  List<ComponentWidget> components = new List<ComponentWidget>();
  Function onComponentChange;

  ContainerComponentModel(
      {ChangedComponent changedComponent, String componentId})
      : super(changedComponent);

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
    if (components.contains(pComponent)) {
      components.remove(pComponent);
    }
    if (pIndex < 0) {
      components.add(pComponent);
    } else {
      components.insert(pIndex, pComponent);
    }

    pComponent.componentModel.coState = CoState.Added;
    if (layout != null) {
      if (layout is CoBorderLayoutContainerWidget) {
        CoBorderLayoutConstraints contraints =
            getBorderLayoutConstraintsFromString(pConstraints);
        layout.addLayoutComponent(pComponent, contraints);
      } else if (layout is CoFormLayoutContainerWidget) {
        layout.addLayoutComponent(pComponent, pConstraints);
      } else if (layout is CoFlowLayoutContainerWidget) {
        layout.addLayoutComponent(pComponent, pConstraints);
      } else if (layout is CoGridLayoutContainerWidget) {
        layout.addLayoutComponent(pComponent, pConstraints);
      }
    }

    if (this.onComponentChange != null) this.onComponentChange();
  }

  void remove(int pIndex) {
    ComponentWidget pComponent = components[pIndex];
    if (layout != null) {
      layout.removeLayoutComponent(pComponent);
    }
    components.removeAt(pIndex);

    if (this.onComponentChange != null) this.onComponentChange();
  }

  void removeWithComponent(ComponentWidget pComponent) {
    int index = components.indexWhere((c) =>
        c.componentModel.componentId.toString() ==
        pComponent.componentModel.componentId.toString());

    if (index >= 0) {
      remove(index);
      pComponent.componentModel.coState = CoState.Free;
    }

    if (this.onComponentChange != null) this.onComponentChange();
  }

  void removeAll() {
    while (components.length > 0) {
      remove(components.length - 1);
    }

    if (this.onComponentChange != null) this.onComponentChange();
  }

  ComponentWidget getComponentWithContraint(String constraint) {
    return components?.firstWhere(
        (component) => component.componentModel.constraints == constraint);
  }

  void updateConstraintsWithWidget(
      ComponentWidget componentWidget, String newConstraints) {
    if (layout != null) {
      layout.removeLayoutComponent(componentWidget);

      if (layout is CoBorderLayoutContainerWidget) {
        CoBorderLayoutConstraints contraints =
            getBorderLayoutConstraintsFromString(newConstraints);
        layout.addLayoutComponent(componentWidget, contraints);
      } else if (layout is CoFormLayoutContainerWidget) {
        layout.addLayoutComponent(componentWidget, newConstraints);
      } else if (layout is CoFlowLayoutContainerWidget) {
        layout.addLayoutComponent(componentWidget, newConstraints);
      } else if (layout is CoGridLayoutContainerWidget) {
        layout.addLayoutComponent(componentWidget, newConstraints);
      }
    }
  }

  void updateComponentProperties(BuildContext context, String componentId,
      ChangedComponent changedComponent) {
    ComponentWidget pComponent = this.components.firstWhere(
        (c) => c.componentModel.componentId == componentId,
        orElse: () => null);

    if (pComponent != null) {
      pComponent.componentModel.updateProperties(context, changedComponent);
    }
    this.preferredSize = changedComponent.getProperty<Size>(
        ComponentProperty.PREFERRED_SIZE, null);
    this.maximumSize = changedComponent.getProperty<Size>(
        ComponentProperty.MAXIMUM_SIZE, null);

    if (layout != null) {
      if (layout is CoBorderLayoutContainerWidget) {
        CoBorderLayoutConstraints contraints =
            layout.getConstraints(pComponent);
        (layout as CoBorderLayoutContainerWidget)
            .addLayoutComponent(pComponent, contraints);
      }
    }

    if (this.onComponentChange != null) this.onComponentChange();
  }

  ILayout createLayoutForHeaderFooterPanel(
      CoContainerWidget container, String layoutData) {
    return CoBorderLayoutContainerWidget.fromLayoutString(
        container, layoutData, null);
  }

  ILayout createLayout(
      CoContainerWidget container, ChangedComponent changedComponent) {
    if (changedComponent.hasProperty(ComponentProperty.LAYOUT)) {
      String layoutRaw =
          changedComponent.getProperty<String>(ComponentProperty.LAYOUT);
      String layoutData =
          changedComponent.getProperty<String>(ComponentProperty.LAYOUT_DATA);

      switch (changedComponent.layoutName) {
        case "BorderLayout":
          {
            return CoBorderLayoutContainerWidget.fromLayoutString(
                container, layoutRaw, layoutData);
          }
          break;
        case "FormLayout":
          {
            return CoFormLayoutContainerWidget.fromLayoutString(
                container, layoutRaw, layoutData);
          }
          break;
        case "FlowLayout":
          {
            return CoFlowLayoutContainerWidget.fromLayoutString(
                container, layoutRaw, layoutData);
          }
          break;
        case "GridLayout":
          {
            return CoGridLayoutContainerWidget.fromLayoutString(
                container, layoutRaw, layoutData);
          }
          break;
      }
    }

    return null;
  }
}
