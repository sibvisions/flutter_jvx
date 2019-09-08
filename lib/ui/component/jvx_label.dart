import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/utils/jvx_alignment.dart';
import 'package:jvx_mobile_v3/utils/jvx_text_align.dart';
import '../../model/component_properties.dart';
import 'jvx_component.dart';
import 'i_component.dart';

class JVxLabel extends JVxComponent implements IComponent {
  String text = "";
  TextAlign verticalAlignment = JVxTextAlign.defaultAlign;
  Alignment horizontalAlignment = JVxAlignment.defaultAlignment;

  JVxLabel(Key componentId, BuildContext context, { this.text }) : super(componentId, context);

  void updateProperties(ComponentProperties properties) {
    super.updateProperties(properties);
    text = properties.getProperty<String>("text", text);
    verticalAlignment = properties.getProperty<TextAlign>("verticalAlignment", JVxTextAlign.defaultAlign);
    horizontalAlignment = properties.getProperty<Alignment>("horizontalAlignment", JVxAlignment.defaultAlignment);
  }

  @override
  Widget getWidget() {
      return 
      SizedBox(
        child: Container(
          alignment: horizontalAlignment,
          color: this.background,
          child: Text(text, 
            key: componentId,
            style: style,
            textAlign: verticalAlignment
          ),
          ),
        
      );
  }
}