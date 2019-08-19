import 'package:flutter/material.dart';
import 'i_component.dart';

class JVxComponent implements IComponent {
  String name;
  Key componentId;
  Color background;
  Color foreground;
  TextStyle style;
  Size preferredSize;
  Size minimumSize;
  Size maximumSize;
  bool isVisible;
  bool enabled;

  Key parentComponentId;
  List<Key> childComponentIds;

  bool get isForegroundSet => foreground!=null;
  bool get isBackgroundSet => background!=null;
  bool get isPreferredSizeSet => preferredSize!=null;
  bool get isMinimumSizeSet => minimumSize!=null;
  bool get isMaximumSizeSet => maximumSize!=null;

  JVxComponent(this.componentId);

  Widget getWidget() {
    return null;
  }
}