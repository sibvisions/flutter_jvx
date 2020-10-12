import 'dart:collection';

import 'package:jvx_flutterclient/model/changed_component.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_model.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_widget.dart';

class ContainerComponentModel extends ComponentModel {
  Queue<ToAddComponent> _toAddComponents = Queue<ToAddComponent>();
  Queue<String> _toUpdateLayout = Queue<String>();
  Queue<ToUpdateComponent> _toUpdateComponentProperties =
      Queue<ToUpdateComponent>();

  Queue<ToAddComponent> get toAddComponents => _toAddComponents;
  Queue<String> get toUpdateLayout => _toUpdateLayout;
  Queue<ToUpdateComponent> get toUpdateComponentProperties =>
      _toUpdateComponentProperties;

  set toAddComponents(Queue<ToAddComponent> newToAddComponents) =>
      _toAddComponents = newToAddComponents;
  set toUpdateLayout(Queue<String> toUpdateLayout) =>
      _toUpdateLayout = toUpdateLayout;
  set toUpdateComponentProperties(
          Queue<ToUpdateComponent> toUpdateComponents) =>
      _toUpdateComponentProperties = toUpdateComponents;

  ContainerComponentModel(
      {ChangedComponent changedComponent, String componentId})
      : super(changedComponent);
}

class ToAddComponent {
  final String constraints;
  final ComponentWidget componentWidget;

  ToAddComponent({
    this.constraints,
    this.componentWidget,
  });
}

class ToUpdateComponent {
  final String componentId;
  final ChangedComponent changedComponent;

  ToUpdateComponent({this.componentId, this.changedComponent});
}
