import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'package:jvx_mobile_v3/model/properties/component_properties.dart';
import 'package:jvx_mobile_v3/model/properties/hex_color.dart';
import 'package:jvx_mobile_v3/utils/jvx_text_style.dart';
import 'i_component.dart';

abstract class JVxComponent implements IComponent {
  String name;
  Key componentId;
  String rawComponentId;
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

  bool get isForegroundSet => foreground != null;
  bool get isBackgroundSet => background != null;
  bool get isPreferredSizeSet => preferredSize != null;
  bool get isMinimumSizeSet => minimumSize != null;
  bool get isMaximumSizeSet => maximumSize != null;

  JVxComponent(this.componentId, this.context);

  void updateProperties(ChangedComponent changedComponent) {
    preferredSize = changedComponent.getProperty<Size>(
        ComponentProperty.PREFERRED_SIZE, null);
    maximumSize = changedComponent.getProperty<Size>(
        ComponentProperty.MAXIMUM_SIZE, null);
    rawComponentId = changedComponent.getProperty<String>(ComponentProperty.ID);
    background =
        changedComponent.getProperty<HexColor>(ComponentProperty.BACKGROUND);
    name = changedComponent.getProperty<String>(ComponentProperty.NAME, name);
    isVisible =
        changedComponent.getProperty<bool>(ComponentProperty.VISIBLE, true);
    style = JVxTextStyle.addFontToTextStyle(
        changedComponent.getProperty<String>(ComponentProperty.FONT, ""),
        style);
    foreground = changedComponent.getProperty<HexColor>(
        ComponentProperty.FOREGROUND, null);
    style = JVxTextStyle.addForecolorToTextStyle(foreground, style);
    enabled =
        changedComponent.getProperty<bool>(ComponentProperty.ENABLED, true);
    parentComponentId = changedComponent.getProperty<String>(
        ComponentProperty.PARENT, parentComponentId);
    constraints = changedComponent.getProperty<String>(
        ComponentProperty.CONSTRAINTS, constraints);
  }
}
