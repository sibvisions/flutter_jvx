import 'package:flutter/material.dart';
import 'i_component.dart';

abstract class JVxComponent implements IComponent {
  String name;
  Key componentId;
  Color background = Colors.white;
  Color foreground;
  TextStyle style = new TextStyle(fontSize: 10.0, color: Colors.black);
  Size preferredSize;
  Size minimumSize;
  Size maximumSize;
  bool isVisible = true;
  bool enabled = true;
  BuildContext context;

  Key parentComponentId;
  List<Key> childComponentIds;

  bool get isForegroundSet => foreground!=null;
  bool get isBackgroundSet => background!=null;
  bool get isPreferredSizeSet => preferredSize!=null;
  bool get isMinimumSizeSet => minimumSize!=null;
  bool get isMaximumSizeSet => maximumSize!=null;

  JVxComponent(this.componentId, this.context);
}