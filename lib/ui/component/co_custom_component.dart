import 'package:flutter/material.dart';
import 'i_component.dart';
import 'component.dart';

class CoCustomComponent extends Component implements IComponent {
  Widget widget = Text('You have to set a widget to this component!');

  CoCustomComponent(GlobalKey componentId, BuildContext context)
      : super(componentId, context);

  @override
  Widget getWidget() {
    return widget;
  }
}
