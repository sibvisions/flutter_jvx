import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:jvx_flutterclient/model/changed_component.dart';
import 'package:jvx_flutterclient/model/properties/component_properties.dart';
import 'package:jvx_flutterclient/model/properties/hex_color.dart';
import 'package:jvx_flutterclient/ui_refactor/component/component_state.dart';
import 'package:jvx_flutterclient/utils/so_text_style.dart';

enum CoState {
  /// Component is added to the widget tree
  Added,

  /// Component is not added to the widget tree
  Free,

  /// Component was destroyed
  Destroyed
}

class ComponentWidget extends StatefulWidget {
  final ComponentModel componentModel;
  final Widget child;

  const ComponentWidget({
    Key key,
    @required this.componentModel,
    @required this.child,
  }) : super(key: key);

  @override
  ComponentWidgetState createState() => ComponentWidgetState();
}

class ComponentWidgetState extends State<ComponentWidget> with ComponentState {
  @override
  void updateProperties(ChangedComponent changedComponent) {
    super.updateProperties(changedComponent);
  }

  @override
  void initState() {
    super.initState();
    widget.componentModel.addListener(
        () => updateProperties(widget.componentModel.currentChangedComponent));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.componentModel,
        builder: (context, value, child) {
          return widget.child;
        });
  }
}

class ComponentModel extends ValueNotifier {
  String componentId;
  ChangedComponent currentChangedComponent;
  ComponentState componentState;

  ComponentModel() : super(null);

  set compId(String componentId) {
    componentId = componentId;
  }

  set changedComponent(ChangedComponent changedComponent) {
    currentChangedComponent = changedComponent;
    notifyListeners();
  }
}
