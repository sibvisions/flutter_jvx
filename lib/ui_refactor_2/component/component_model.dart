import 'dart:collection';

import 'package:flutter/material.dart';

import '../../jvx_flutterclient.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import '../../ui/component/i_component.dart';
import '../container/container_component_model.dart';
import 'component_widget.dart';

class ComponentModel extends ValueNotifier {
  Queue<ToUpdateComponent> _toUpdateComponents = Queue<ToUpdateComponent>();

  String componentId;
  String parentComponentId;
  ChangedComponent _changedComponent;
  ComponentWidgetState componentState;
  CoState coState;
  String constraints;
  bool isVisible = true;
  Size _preferredSize;
  Size _minimumSize;
  Size _maximumSize;
  ButtonPressedCallback onButtonPressed;

  Queue<ToUpdateComponent> get toUpdateComponents => _toUpdateComponents;

  set toUpdateComponents(Queue<ToUpdateComponent> toUpdateComponents) =>
      _toUpdateComponents = toUpdateComponents;

  bool get isPreferredSizeSet => preferredSize != null;
  bool get isMinimumSizeSet => minimumSize != null;
  bool get isMaximumSizeSet => maximumSize != null;
  Size get preferredSize => _preferredSize;
  set preferredSize(Size size) => _preferredSize = size;
  Size get minimumSize => _minimumSize;
  set minimumSize(Size size) => _minimumSize = size;
  Size get maximumSize => _maximumSize;
  set maximumSize(Size size) => _maximumSize = size;

  set compId(String newComponentId) {
    componentId = newComponentId;
  }

  ChangedComponent get changedComponent {
    if (_toUpdateComponents != null && _toUpdateComponents.length > 0) {
      return _toUpdateComponents.last.changedComponent;
    }
    return _changedComponent;
  }

  ChangedComponent get firstChangedComponent {
    return _changedComponent;
  }

  ComponentModel(this._changedComponent) : super(_changedComponent) {
    if (this._changedComponent != null) {
      this.compId = this._changedComponent.id;
      this.toUpdateComponents.add(ToUpdateComponent(
          changedComponent: this._changedComponent,
          componentId: this._changedComponent.id));

      this.updateProperties(changedComponent);
    }
  }

  void updateProperties(ChangedComponent changedComponent) {
    parentComponentId = changedComponent.getProperty<String>(
        ComponentProperty.PARENT, parentComponentId);
    isVisible = changedComponent.getProperty<bool>(
        ComponentProperty.VISIBLE, isVisible);
    constraints = changedComponent.getProperty<String>(
        ComponentProperty.CONSTRAINTS, constraints);
    preferredSize = changedComponent.getProperty<Size>(
        ComponentProperty.PREFERRED_SIZE, _preferredSize);
    maximumSize = changedComponent.getProperty<Size>(
        ComponentProperty.MAXIMUM_SIZE, _maximumSize);
    minimumSize = changedComponent.getProperty<Size>(
        ComponentProperty.MINIMUM_SIZE, _minimumSize);
  }

  void update() {
    if (changedComponent != null) this.updateProperties(changedComponent);
    notifyListeners();
  }
}
