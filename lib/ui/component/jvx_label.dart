import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'package:jvx_mobile_v3/model/properties/component_properties.dart';
import 'package:jvx_mobile_v3/ui/component/i_component.dart';
import 'package:jvx_mobile_v3/ui/component/jvx_component.dart';
import 'package:jvx_mobile_v3/utils/jvx_alignment.dart';
import 'package:jvx_mobile_v3/utils/jvx_text_align.dart';

class JVxLabel extends JVxComponent implements IComponent {
  String text = "";
  TextAlign verticalAlignment = JVxTextAlign.defaultAlign;
  Alignment horizontalAlignment = JVxAlignment.defaultAlignment;

  JVxLabel(Key componentId, BuildContext context) : super(componentId, context);

  static String utf8convert(String text) {
    List<int> bytes = text.toString().codeUnits;
    return utf8.decode(bytes);
  }

  void updateProperties(ChangedComponent changedProperties) {
    super.updateProperties(changedProperties);
    text = utf8convert(changedProperties.getProperty<String>(ComponentProperty.TEXT, text));
    verticalAlignment = changedProperties.getProperty<TextAlign>(ComponentProperty.VERTICAL_ALIGNMENT, JVxTextAlign.defaultAlign);
    horizontalAlignment = changedProperties.getProperty<Alignment>(ComponentProperty.HORIZONTAL_ALIGNMENT, JVxAlignment.defaultAlignment);
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