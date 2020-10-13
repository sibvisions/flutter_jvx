import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/model/changed_component.dart';
import 'package:jvx_flutterclient/model/properties/component_properties.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_model.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/container/container_component_model.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/co_border_layout_container_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/co_form_layout_container_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/co_layout.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/i_layout.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/widgets/co_border_layout_constraint.dart';

import '../../jvx_flutterclient.dart';

class CoContainerWidget extends ComponentWidget {
  CoContainerWidget({ContainerComponentModel componentModel})
      : super(componentModel: componentModel);

  static CoContainerWidgetState of(BuildContext context) =>
      context.findAncestorStateOfType<CoContainerWidgetState>();

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

    pComponent.componentModel.coState = CoState.Added;
    if (layout != null) {
      if (layout is CoBorderLayoutContainerWidget) {
        CoBorderLayoutConstraints contraints =
            getBorderLayoutConstraintsFromString(pConstraints);
        layout.addLayoutComponent(pComponent, contraints);
      } else if (layout is CoFormLayoutContainerWidget) {
        layout.addLayoutComponent(pComponent, pConstraints);
      }
      /* else if (layout is CoFlowLayout) {
        layout.addLayoutComponent(pComponent, pConstraints);
      } else if (layout is CoGridLayout) {
        layout.addLayoutComponent(pComponent, pConstraints);
      }
      */
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
        c.componentModel.componentId.toString() ==
        pComponent.componentModel.componentId.toString());

    if (index >= 0) {
      remove(index);
      pComponent.componentModel.componentState.state = CoState.Free;
      pComponent.componentModel.coState = CoState.Free;
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
      String componentId, ChangedComponent changedComponent) {
    ComponentWidget pComponent = this.components.firstWhere(
        (c) => c.componentModel.componentId == componentId,
        orElse: () => null);

    if (pComponent != null) {
      pComponent.componentModel.toUpdateComponents.add(ToUpdateComponent(
          changedComponent: changedComponent, componentId: componentId));
      pComponent.componentModel.update();
    }
    preferredSize = changedComponent.getProperty<Size>(
        ComponentProperty.PREFERRED_SIZE, null);
    maximumSize = changedComponent.getProperty<Size>(
        ComponentProperty.MAXIMUM_SIZE, null);

    if (layout != null) {
      if (layout is CoBorderLayoutContainerWidget) {
        CoBorderLayoutConstraints contraints =
            layout.getConstraints(pComponent);
        (layout as CoBorderLayoutContainerWidget)
            .addLayoutComponent(pComponent, contraints);
      }
    }
  }

  ILayout _createLayout(
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
        /*
        case "FlowLayout":
          {
            return CoFlowLayout.fromLayoutString(
                container, layoutRaw, layoutData);
          }
          break;
        case "GridLayout":
          {
            return CoGridLayout.fromLayoutString(
                container, layoutRaw, layoutData);
          }
          break;
        */
      }
    }

    return null;
  }

  void _update() {
    this._updateComponents(
        (widget.componentModel as ContainerComponentModel).toAddComponents);

    (widget.componentModel as ContainerComponentModel).toAddComponents =
        Queue<ToAddComponent>();

    this._updateComponentProperties(
        (widget.componentModel as ContainerComponentModel).toUpdateComponents);

    (widget.componentModel as ContainerComponentModel).toUpdateComponents =
        Queue<ToUpdateComponent>();

    this._updateLayoutData(
        (widget.componentModel as ContainerComponentModel).toUpdateLayout);

    (widget.componentModel as ContainerComponentModel).toUpdateLayout =
        Queue<String>();
  }

  void _updateComponents(Queue<ToAddComponent> toAddComponents) {
    toAddComponents.forEach((toAddComponent) {
      this.addWithConstraints(
          toAddComponent.componentWidget, toAddComponent.constraints);
    });
  }

  void _updateComponentProperties(Queue<ToUpdateComponent> toUpdateComponents) {
    toUpdateComponents.forEach((toUpdateComponent) {
      ComponentWidget componentWidget = this.components.firstWhere(
          (component) =>
              component.componentModel.componentId ==
              toUpdateComponent.componentId,
          orElse: () => null);
      if (componentWidget != null) {
        componentWidget.componentModel.toUpdateComponents
            .add(toUpdateComponent);
        componentWidget.componentModel.update();
      }
    });
  }

  void _updateLayoutData(Queue<String> toUpdateLayout) {
    toUpdateLayout.forEach((layoutData) {
      this.layout?.updateLayoutData(layoutData);
    });
  }

  @override
  void initState() {
    super.initState();
    layout = _createLayout(widget, widget.componentModel.changedComponent);
    this._update();

    widget.componentModel.addListener(() => setState(() => this._update()));
  }

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }
}
