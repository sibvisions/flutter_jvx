import 'package:flutter/material.dart';
import 'jvx_component.dart';

class JVxButton extends JVxComponent {
  String text = "";

  JVxButton(Key componentId) : super(componentId) {
    this.background = Colors.grey;
  }

  void buttonPressed() {
  
  }

  Widget getWidget() {
    return MaterialButton(
      key: this.componentId, 
      onPressed: buttonPressed,
      child: Text(text, 
        style: TextStyle(
          backgroundColor: this.background,
        ),
      ),
    );
  }
}