import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';

/// Component state defines current state
enum JVxComponentState {
  /// Component is added to the widget tree
  Added,
  /// Component is not added to the widget tree
  Free,
  /// Component was destroyed
  Destroyed
}

abstract class IComponent {
  String name;
  Key componentId;
  JVxComponentState state;
  Color background;
  Color foreground;
  TextStyle style;
  Size preferredSize;
  Size minimumSize;
  Size maximumSize;
  bool isVisible;
  bool enabled;
  String constraints;
  BuildContext context;

  String parentComponentId;
  List<Key> childComponentIds;

  bool get isForegroundSet;
  bool get isBackgroundSet;
  bool get isPreferredSizeSet;
  bool get isMinimumSizeSet;
  bool get isMaximumSizeSet;

  void updateProperties(ChangedComponent changedComponent);

  Widget getWidget();
}