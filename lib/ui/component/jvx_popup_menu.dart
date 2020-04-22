import 'package:flutter/material.dart';
import '../../ui/component/i_component.dart';
import '../../ui/component/jvx_component.dart';

class JVxMenuItem extends JVxComponent implements IComponent {
  List<JVxMenuItem> items;

  JVxMenuItem(GlobalKey componentId, BuildContext context)
      : super(componentId, context);

  @override
  Widget getWidget() {
    return null;
  }
}
