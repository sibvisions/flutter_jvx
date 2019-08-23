import 'package:flutter/material.dart';
import 'jvx_component.dart';

class JVxButton extends JVxComponent {
  JVxButton(Key componentId) : super(componentId);

  void buttonPressed() {
  
  }

  Widget getWidget() {
    return MaterialButton(
      key: this.componentId, 
      onPressed: buttonPressed,
      child: Text(this.name, 
        style: TextStyle(
          backgroundColor: this.background,
        ),
      ),
    );
  }
}