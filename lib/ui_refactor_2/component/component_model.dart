import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/model/changed_component.dart';
import 'package:jvx_flutterclient/model/properties/component_properties.dart';
import 'package:jvx_flutterclient/ui/component/i_component.dart';
import 'package:jvx_flutterclient/ui/screen/so_component_data.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_widget.dart';

class ComponentModel extends ValueNotifier {
  String componentId;
  String parentComponentId;
  ChangedComponent currentChangedComponent;
  ComponentWidgetState componentState;
  SoComponentData data;
  String dataProvider;
  CoState coState;
  String constraints;
  bool isVisible = true;

  ComponentModel({this.currentChangedComponent}) : super(null) {
    this.compId = currentChangedComponent.id;
    this.updateProperties(this.currentChangedComponent);
  }

  void updateProperties(ChangedComponent changedComponent) {
    parentComponentId = changedComponent.getProperty<String>(
        ComponentProperty.PARENT, parentComponentId);
    isVisible = changedComponent.getProperty<bool>(
        ComponentProperty.VISIBLE, isVisible);
    constraints = changedComponent.getProperty<String>(
        ComponentProperty.CONSTRAINTS, constraints);
  }

  set compId(String newComponentId) {
    componentId = newComponentId;
  }

  set changedComponent(ChangedComponent changedComponent) {
    currentChangedComponent = changedComponent;
    compId = changedComponent.id;
    notifyListeners();
  }
}
