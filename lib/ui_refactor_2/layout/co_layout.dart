import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/container/co_container_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/editor/co_editor_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/i_layout.dart';

mixin CoLayout<E> implements ILayout<E> {
  Key key = UniqueKey();

  StateSetter setState;

  /// The constraints for all components used by this layout.
  Map<ComponentWidget, E> layoutConstraints = <ComponentWidget, E>{};

  /// the layout margins. */
  EdgeInsets margins = EdgeInsets.zero;

  /// the horizontal gap between components.
  int horizontalGap = 0;

  /// the vertical gap between components.
  int verticalGap = 0;

  CoContainerWidget container;

  Size preferredSize;
  Size minimumSize;
  Size maximumSize;

  String rawLayoutData;
  String rawLayoutString;

  Map<String, Key> keys = <String, Key>{};

  bool get isPreferredSizeSet => preferredSize != null;
  bool get isMinimumSizeSet => minimumSize != null;
  bool get isMaximumSizeSet => maximumSize != null;

  Key getKeyByComponentId(String componentId) {
    return keys[componentId];
  }

  Key createKey(String componentId) {
    if (keys[componentId] == null) {
      keys[componentId] = GlobalKey(debugLabel: componentId);
    }
    return keys[componentId];
  }

  void parseFromString(String layout) {
    List<String> parameter = layout?.split(",");

    double top = double.parse(parameter[1]);
    double left = double.parse(parameter[2]);
    double bottom = double.parse(parameter[3]);
    double right = double.parse(parameter[4]);

    margins = EdgeInsets.fromLTRB(left, top, right, bottom);
    horizontalGap = int.parse(parameter[5]);
    verticalGap = int.parse(parameter[6]);
  }

  static String getLayoutName(String layoutString) {
    List<String> parameter = layoutString?.split(",");
    if (parameter != null && parameter.length > 0) {
      return parameter[0];
    }

    return null;
  }

  void updateLayoutString(String layoutString) {
    this.rawLayoutString = layoutString;
  }

  void updateLayoutData(String layoutData) {
    this.rawLayoutData = layoutData;
  }
}
