import 'package:flutter/material.dart';
import '../../model/changed_component.dart';

/// Component state defines current state
enum CoState {
  /// Component is added to the widget tree
  Added,

  /// Component is not added to the widget tree
  Free,

  /// Component was destroyed
  Destroyed
}

abstract class IComponent {
  String name;
  GlobalKey componentId;
  String rawComponentId;
  CoState state;
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

  int verticalAlignment;
  int horizontalAlignment;

  bool get isForegroundSet;
  bool get isBackgroundSet;
  bool get isPreferredSizeSet;
  bool get isMinimumSizeSet;
  bool get isMaximumSizeSet;

  void updateProperties(ChangedComponent changedComponent);

  Widget getWidget();
}

abstract class IComponentWidget extends StatefulWidget {}

abstract class IComponentWidgetState<T extends StatefulWidget>
    extends State<T> {
  String name;
  GlobalKey componentId;
  String rawComponentId;
  CoState state;
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

  int verticalAlignment;
  int horizontalAlignment;

  bool get isForegroundSet;
  bool get isBackgroundSet;
  bool get isPreferredSizeSet;
  bool get isMinimumSizeSet;
  bool get isMaximumSizeSet;

  void updateProperties(ChangedComponent changedComponent);
}
