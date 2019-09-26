import 'dart:convert';

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

  JVxLabel(Key componentId, BuildContext context) : super(componentId, context);

  static String utf8convert(String text) {
    List<int> bytes = text.toString().codeUnits;
    return utf8.decode(bytes);
  }

  void updateProperties(ComponentProperties properties) {
    super.updateProperties(properties);
    text = utf8convert(properties.getProperty<String>("text", text));
    verticalAlignment = properties.getProperty<TextAlign>("verticalAlignment", JVxTextAlign.defaultAlign);
    horizontalAlignment = properties.getProperty<Alignment>("horizontalAlignment", JVxAlignment.defaultAlignment);
  }

  @override
  Widget getWidget() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.minWidth,
          height: constraints.minHeight,
          key: componentId,
          child: Container(
            width:  MediaQuery.of(context).size.width * 0.5,
            alignment: horizontalAlignment,
            color: this.background,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(text,
                  style: style,
                  textAlign: verticalAlignment
              ),
            ),
          )
        );
      }
    );
  }
}