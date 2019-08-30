import 'package:flutter/material.dart';
import '../../model/component_properties.dart';
import 'jvx_component.dart';
import 'i_component.dart';

class JVxLabel extends JVxComponent implements IComponent {
  String text = "";

  JVxLabel(Key componentId, BuildContext context, { this.text, TextStyle style }) : super(componentId, context) {
      super.style = style;
  }

  void updateProperties(ComponentProperties properties) {
    super.updateProperties(properties);
    text = properties.getProperty("text");
  }

  @override
  Widget getWidget() {
      TextAlign align = TextAlign.left;

      return 
      SizedBox(
        child: Container(
          color: this.background,
          child: Text(text, 
            key: componentId,
            style: style,
            textAlign: align
          ),
        ),
      );
  }
}