import 'package:flutter/material.dart';
import '../../ui/component/i_component.dart';
import '../../ui/component/jvx_component.dart';

class JVxCustomComponent extends JVxComponent implements IComponent {
  Widget widget = Text('You have to set a widget to this component!');

  JVxCustomComponent(GlobalKey componentId, BuildContext context) : super(componentId, context);

  @override
  Widget getWidget() {
    return widget;
  }
}