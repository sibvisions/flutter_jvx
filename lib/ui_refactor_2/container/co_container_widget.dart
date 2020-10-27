import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/new_layout/co_border_layout_container_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/new_layout/co_form_layout_container_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/new_layout/layout_helper.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/new_layout/layout_key_manager.dart';
import 'package:jvx_flutterclient/ui_refactor_2/screen/component_screen_widget.dart';

import '../../jvx_flutterclient.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import '../component/component_widget.dart';
import '../layout/co_flow_layout_container_widget.dart';
import '../layout/co_grid_layout_container_widget.dart';
import '../layout/co_layout.dart';
import '../layout/i_layout.dart';
import '../layout/widgets/co_border_layout_constraint.dart';
import 'container_component_model.dart';

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
  Map<ComponentWidget, String> _layoutConstraints = <ComponentWidget, String>{};

  // For FormLayout
  bool _valid = false;

  LayoutKeyManager _keyManager = LayoutKeyManager();

  Map<ComponentWidget, String> get layoutConstraints => _layoutConstraints;

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
    if (_layoutConstraints[pComponent] != null) {
      _layoutConstraints.remove(pComponent);
    }
    _layoutConstraints[pComponent] = pConstraints;

    pComponent.componentModel.coState = CoState.Added;

    _valid = false;
  }

  void remove(ComponentWidget component) {
    (widget.componentModel as ContainerComponentModel)
        .toAddComponents
        .removeWhere((element) =>
            element.componentWidget.componentModel.componentId ==
            component.componentModel.componentId);
    setState(() => _layoutConstraints.remove(component));

    _valid = false;
  }

  void removeWithComponent(ComponentWidget pComponent) {
    remove(pComponent);
    pComponent.componentModel.coState = CoState.Free;
    pComponent.componentModel.update();
  }

  void removeAll() {
    this._layoutConstraints = <ComponentWidget, String>{};
  }

  ComponentWidget getComponentWithContraint(String constraint) {
    return this._layoutConstraints?.keys?.firstWhere((component) =>
        component.componentModel.componentState.constraints == constraint);
  }

  void updateComponentProperties(
      String componentId, ChangedComponent changedComponent) {
    ComponentWidget pComponent = this._layoutConstraints?.keys?.firstWhere(
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

    // if (layout != null) {
    //   if (layout is CoBorderLayoutContainerWidget) {
    //     CoBorderLayoutConstraints contraints =
    //         layout.getConstraints(pComponent);
    //     (layout as CoBorderLayoutContainerWidget)
    //         .addLayoutComponent(pComponent, contraints);
    //   }
    // }
  }

  void update() {
    bool update = ComponentScreenWidget.of(context)
        ?.widget
        ?.responseData
        ?.screenGeneric
        ?.update;
    if (update != null && !update) {
      this.removeAll();
    }

    this._updateComponents(
        (widget.componentModel as ContainerComponentModel).toAddComponents);

    // (widget.componentModel as ContainerComponentModel).toAddComponents =
    //     Queue<ToAddComponent>();

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
      if (!this._layoutConstraints.containsKey(toAddComponent.componentWidget))
        setState(() => this.addWithConstraints(
            toAddComponent.componentWidget, toAddComponent.constraints));
    });
  }

  void _updateComponentProperties(Queue<ToUpdateComponent> toUpdateComponents) {
    toUpdateComponents.forEach((toUpdateComponent) {
      ComponentWidget componentWidget = this._layoutConstraints.keys.firstWhere(
          (component) =>
              component.componentModel.componentId ==
              toUpdateComponent.componentId,
          orElse: () => null);
      if (componentWidget != null) {
        componentWidget.componentModel.toUpdateComponents
            .add(toUpdateComponent);
        componentWidget.componentModel.update();
      }

      preferredSize = widget.componentModel.changedComponent
          .getProperty<Size>(ComponentProperty.PREFERRED_SIZE, null);
      maximumSize = widget.componentModel.changedComponent
          .getProperty<Size>(ComponentProperty.MAXIMUM_SIZE, null);
    });
  }

  ComponentWidget getCompByConstraint(CoBorderLayoutConstraints constraints) {
    return this._layoutConstraints.keys.firstWhere(
        (component) =>
            LayoutHelper.getBorderLayoutConstraint(
                component.componentModel.constraints) ==
            constraints,
        orElse: () => null);
  }

  Widget getLayout(
      CoContainerWidget container, ChangedComponent changedComponent) {
    if (changedComponent.hasProperty(ComponentProperty.LAYOUT)) {
      String layoutRaw =
          changedComponent.getProperty<String>(ComponentProperty.LAYOUT);
      String layoutData =
          changedComponent.getProperty<String>(ComponentProperty.LAYOUT_DATA);

      switch (changedComponent.layoutName) {
        case 'BorderLayout':
          return getBorderLayout(layoutRaw);
          break;
        case 'FormLayout':
          return getFormLayout(layoutRaw, layoutData);
          break;
      }
    }

    return null;
  }

  Widget getBorderLayout(String layoutString) {
    return CoBorderLayoutContainerWidget(
      key: UniqueKey(),
      center: getCompByConstraint(CoBorderLayoutConstraints.Center),
      north: getCompByConstraint(CoBorderLayoutConstraints.North),
      south: getCompByConstraint(CoBorderLayoutConstraints.South),
      east: getCompByConstraint(CoBorderLayoutConstraints.East),
      west: getCompByConstraint(CoBorderLayoutConstraints.West),
      container: widget,
      keyManager: _keyManager,
      layoutString: layoutString,
    );
  }

  Widget getFormLayout(String layoutString, String layoutData) {
    return CoFormLayoutContainerWidget(
      key: UniqueKey(),
      container: widget,
      keyManager: _keyManager,
      layoutString: layoutString,
      layoutData: layoutData,
      valid: _valid,
      layoutConstraints: this._layoutConstraints,
    );
  }

  void _updateLayoutData(Queue<String> toUpdateLayout) {
    toUpdateLayout.forEach((layoutData) {
      this.layout?.updateLayoutData(layoutData);
    });
  }

  @override
  void didUpdateWidget(CoContainerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    this.update();

    widget.componentModel.addListener(() {
      setState(() {
        this.update();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    this.update();

    widget.componentModel.addListener(() {
      setState(() {
        this.update();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }
}
