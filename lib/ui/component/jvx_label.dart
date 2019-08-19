import 'package:flutter/material.dart';
import 'jvx_component.dart';
import 'i_component.dart';

class JVxLabel extends JVxComponent implements IComponent {
  String text = "";

  JVxLabel(Key componentId, { this.text, TextStyle style }) : super(componentId) {
      super.style = style;
  }

  @override
  Widget getWidget() {
      TextAlign align = TextAlign.left;

      return new Text(text, 
                key: componentId, 
                style: style,
                textAlign: align
              );
  }
}