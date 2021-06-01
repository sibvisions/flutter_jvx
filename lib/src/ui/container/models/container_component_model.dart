import 'package:flutter/material.dart';

import '../../../models/api/response_objects/response_data/component/changed_component.dart';
import '../../../models/api/response_objects/response_data/component/component_properties.dart';
import '../../component/component_widget.dart';
import '../../component/model/component_model.dart';
import '../../layout/layout/border_layout/border_layout_model.dart';
import '../../layout/layout/border_layout/co_border_layout_container_widget.dart';
import '../../layout/layout/co_layout_widget.dart';
import '../../layout/layout/flow_layout/co_flow_layout_container_widget.dart';
import '../../layout/layout/flow_layout/flow_layout_model.dart';
import '../../layout/layout/form_layout/co_form_layout_container_widget.dart';
import '../../layout/layout/form_layout/form_layout_model.dart';
import '../../layout/layout/grid_layout/co_grid_layout_container_widget.dart';
import '../../layout/layout/grid_layout/grid_layout_model.dart';
import '../../layout/widgets/co_border_layout_constraint.dart';
import '../../screen/core/so_screen.dart';
import '../co_container_widget.dart';

class ContainerComponentModel extends ComponentModel {
  List<ComponentWidget> components = <ComponentWidget>[];

  String? layoutData;
  String? layoutString;

  CoLayoutWidget? layout;

  get layoutName {
    List<String>? parameter = layoutString?.split(",");
    if (parameter != null && parameter.length > 0) {
      return parameter[0];
    }

    return null;
  }

  ContainerComponentModel({required ChangedComponent changedComponent})
      : super(changedComponent: changedComponent);

  @override
  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    layoutData = changedComponent.getProperty<String>(
        ComponentProperty.LAYOUT_DATA, layoutData);
    layoutString = changedComponent.getProperty<String>(
        ComponentProperty.LAYOUT, layoutString);

    super.updateProperties(context, changedComponent);
  }

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
      ComponentWidget pComponent, String? pConstraints, int pIndex) {
    if (components.contains(pComponent)) {
      components.remove(pComponent);
    }
    if (pIndex < 0) {
      components.add(pComponent);
    } else {
      components.insert(pIndex, pComponent);
    }

    pComponent.componentModel.state = CoState.Added;
    if (layout != null) {
      if (layout is CoBorderLayoutContainerWidget) {
        CoBorderLayoutConstraints contraints =
            getBorderLayoutConstraintsFromString(pConstraints!);
        layout!.layoutModel.addLayoutComponent(pComponent, contraints);
      } else if (layout is CoFormLayoutContainerWidget) {
        layout!.layoutModel.addLayoutComponent(pComponent, pConstraints);
      } else if (layout is CoFlowLayoutContainerWidget) {
        layout!.layoutModel.addLayoutComponent(pComponent, pConstraints);
      } else if (layout is CoGridLayoutContainerWidget) {
        layout!.layoutModel.addLayoutComponent(pComponent, pConstraints);
      }
    }

    // notifyListeners();
  }

  void remove(int pIndex) {
    ComponentWidget pComponent = components[pIndex];
    if (layout != null) {
      layout!.layoutModel.removeLayoutComponent(pComponent);
    }
    components.removeAt(pIndex);
  }

  void removeWithComponent(ComponentWidget pComponent) {
    int index = components.indexWhere((c) =>
        c.componentModel.componentId.toString() ==
        pComponent.componentModel.componentId.toString());

    if (index >= 0) {
      remove(index);
      pComponent.componentModel.state = CoState.Free;
    }

    // notifyListeners();
  }

  void removeAll() {
    while (components.length > 0) {
      remove(components.length - 1);
    }

    // notifyListeners();
  }

  ComponentWidget getComponentWithContraint(String constraint) {
    return components.firstWhere(
        (component) => component.componentModel.constraints == constraint);
  }

  void updateConstraintsWithWidget(
      ComponentWidget componentWidget, String newConstraints) {
    if (layout != null) {
      layout!.layoutModel.removeLayoutComponent(componentWidget);

      if (layout is CoBorderLayoutContainerWidget) {
        CoBorderLayoutConstraints contraints =
            getBorderLayoutConstraintsFromString(newConstraints);
        layout!.layoutModel.addLayoutComponent(componentWidget, contraints);
      } else if (layout is CoFormLayoutContainerWidget) {
        layout!.layoutModel.addLayoutComponent(componentWidget, newConstraints);
      } else if (layout is CoFlowLayoutContainerWidget) {
        layout!.layoutModel.addLayoutComponent(componentWidget, newConstraints);
      } else if (layout is CoGridLayoutContainerWidget) {
        layout!.layoutModel.addLayoutComponent(componentWidget, newConstraints);
      }
    }
  }

  void updateComponentProperties(BuildContext context, String componentId,
      ChangedComponent changedComponent) {
    ComponentWidget pComponent = this
        .components
        .firstWhere((c) => c.componentModel.componentId == componentId);

    preferredSize = changedComponent.getProperty<Size>(
        ComponentProperty.PREFERRED_SIZE, null);
    maximumSize = changedComponent.getProperty<Size>(
        ComponentProperty.MAXIMUM_SIZE, null);

    if (layout != null) {
      if (layout is CoBorderLayoutContainerWidget) {
        CoBorderLayoutConstraints contraints =
            layout!.layoutModel.getConstraints(pComponent);
        (layout as CoBorderLayoutContainerWidget)
            .layoutModel
            .addLayoutComponent(pComponent, contraints);
      }
    }

    // notifyListeners();
  }

  CoLayoutWidget createLayoutForHeaderFooterPanel(
      CoContainerWidget container, String layoutData) {
    return CoBorderLayoutContainerWidget(
        layoutModel:
            BorderLayoutModel.fromLayoutString(container, layoutData, null));
  }

  CoLayoutWidget? createLayout(
      CoContainerWidget container, ChangedComponent changedComponent) {
    if (changedComponent.hasProperty(ComponentProperty.LAYOUT) ||
        ((container.componentModel as ContainerComponentModel).layoutString !=
                null &&
            (container.componentModel as ContainerComponentModel)
                .layoutString!
                .isNotEmpty)) {
      String? layoutRaw =
          changedComponent.getProperty<String>(ComponentProperty.LAYOUT, null);
      String? layoutData = changedComponent.getProperty<String>(
          ComponentProperty.LAYOUT_DATA, null);

      if (layoutRaw == null || layoutRaw.isEmpty) {
        layoutRaw =
            (container.componentModel as ContainerComponentModel).layoutString;
        layoutData =
            (container.componentModel as ContainerComponentModel).layoutData;
      }

      switch (layoutName) {
        case "BorderLayout":
          {
            return CoBorderLayoutContainerWidget(
                layoutModel: BorderLayoutModel.fromLayoutString(
                    container, layoutRaw ?? '', layoutData));
          }
        case "FormLayout":
          {
            return CoFormLayoutContainerWidget(
                layoutModel: FormLayoutModel.fromLayoutString(
                    container, layoutRaw ?? '', layoutData ?? ''));
          }
        case "FlowLayout":
          {
            return CoFlowLayoutContainerWidget(
              layoutModel: FlowLayoutModel.fromLayoutString(
                  container, layoutRaw ?? '', layoutData ?? ''),
            );
          }
        case "GridLayout":
          {
            return CoGridLayoutContainerWidget(
              layoutModel: GridLayoutModel.fromLayoutString(
                  container, layoutRaw ?? '', layoutData ?? ''),
            );
          }
      }

      return null;
    }
  }
}
