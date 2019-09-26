import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/utils/hex_color.dart';
import 'package:jvx_mobile_v3/utils/jvx_text_style.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';
import '../../model/component_properties.dart';
import 'i_component.dart';

abstract class JVxComponent implements IComponent {
  String name;
  Key componentId;
  JVxComponentState state = JVxComponentState.Free;
  Color background = Colors.transparent;
  Color foreground;
  TextStyle style = new TextStyle(fontSize: 16.0, color: Colors.black);
  Size preferredSize;
  Size minimumSize;
  Size maximumSize;
  bool isVisible = true;
  bool enabled = true;
  String constraints = "";
  BuildContext context;

  String parentComponentId;
  List<Key> childComponentIds;

  bool get isForegroundSet => foreground!=null;
  bool get isBackgroundSet => background!=null;
  bool get isPreferredSizeSet => preferredSize!=null;
  bool get isMinimumSizeSet => minimumSize!=null;
  bool get isMaximumSizeSet => maximumSize!=null;

  JVxComponent(this.componentId, this.context);

  void updateProperties(ComponentProperties properties) {
    background = properties.getProperty<HexColor>("background");
    name = properties.getProperty<String>("name");
    isVisible = properties.getProperty<bool>("visible", true);
    style = JVxTextStyle.addFontToTextStyle(properties.getProperty<String>("font", ""), style);
    foreground = properties.getProperty<HexColor>("foreground", null);
    style = JVxTextStyle.addForecolorToTextStyle(foreground, style);
    enabled = properties.getProperty<bool>("enabled", true);
    parentComponentId = properties.getProperty<String>("parent", parentComponentId);
    constraints = properties.getProperty<String>("constraints", constraints);
  }
}