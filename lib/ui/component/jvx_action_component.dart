import 'package:flutter/material.dart';
import '../../ui/component/jvx_component.dart';

typedef ButtonPressedCallback = void Function(String componentId, String label);

class JVxActionComponent extends JVxComponent {
  ButtonPressedCallback onButtonPressed; 

  JVxActionComponent(Key componentId, BuildContext context) : super(componentId, context);
  
  @override
  Widget getWidget() {
    return null;
  }

}