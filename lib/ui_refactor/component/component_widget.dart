import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/jvx_flutterclient.dart';

import 'package:jvx_flutterclient/model/changed_component.dart';
import 'package:jvx_flutterclient/model/properties/component_properties.dart';
import 'package:jvx_flutterclient/model/properties/hex_color.dart';
import 'package:jvx_flutterclient/ui_refactor/component/component_state.dart';
import 'package:jvx_flutterclient/utils/so_text_style.dart';
import 'package:universal_html/prefer_universal/js.dart';

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

  static ComponentWidgetState of(BuildContext context) {
    return context.findAncestorStateOfType<ComponentWidgetState>();
  }

  @override
  ComponentWidgetState createState() => ComponentWidgetState();
}

class ComponentWidgetState extends State<ComponentWidget> {
  @override
  void initState() {
    super.initState();
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
