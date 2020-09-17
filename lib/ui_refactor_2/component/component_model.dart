import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/model/changed_component.dart';
import 'package:jvx_flutterclient/ui/screen/so_component_data.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_widget.dart';

class ComponentModel extends ValueNotifier {
  String componentId;
  ChangedComponent currentChangedComponent;
  ComponentWidgetState componentState;
  SoComponentData data;
  String dataProvider;

  ComponentModel(this.componentId) : super(null);

  set compId(String componentId) {
    componentId = componentId;
  }

  set changedComponent(ChangedComponent changedComponent) {
    currentChangedComponent = changedComponent;
    notifyListeners();
  }
}
