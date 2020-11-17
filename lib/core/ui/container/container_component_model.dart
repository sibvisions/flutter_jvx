import 'dart:collection';

import '../../models/api/component/changed_component.dart';
import '../component/component_model.dart';
import '../component/component_widget.dart';

class ContainerComponentModel extends ComponentModel {
  Queue<String> _toUpdateLayout = Queue<String>();
  Queue<ToUpdateComponent> _toUpdateComponentProperties =
      Queue<ToUpdateComponent>();

  Queue<String> get toUpdateLayout => _toUpdateLayout;
  Queue<ToUpdateComponent> get toUpdateComponentProperties =>
      _toUpdateComponentProperties;

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
