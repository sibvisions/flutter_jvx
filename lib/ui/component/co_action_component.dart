import 'package:flutter/material.dart';
import 'component.dart';

typedef ButtonPressedCallback = void Function(String componentId, String label);

abstract class CoActionComponent extends Component {
  ButtonPressedCallback onButtonPressed;

  CoActionComponent(GlobalKey componentId, BuildContext context)
      : super(componentId, context);

  @override
  Widget getWidget() {
    return null;
  }
}
