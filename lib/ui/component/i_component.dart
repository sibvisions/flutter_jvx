import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/model/component_properties.dart';

abstract class IComponent {
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
  BuildContext context;

  Key parentComponentId;
  List<Key> childComponentIds;

  bool get isForegroundSet;
  bool get isBackgroundSet;
  bool get isPreferredSizeSet;
  bool get isMinimumSizeSet;
  bool get isMaximumSizeSet;

  void updateProperties(ComponentProperties properties);

  Widget getWidget();
}