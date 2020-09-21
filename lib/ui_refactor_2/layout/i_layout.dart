import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/container/co_container_widget.dart';

abstract class ILayout<E> {
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

  bool get isPreferredSizeSet;
  bool get isMinimumSizeSet;
  bool get isMaximumSizeSet;

  ILayout.fromLayoutString(
      CoContainerWidget container, String layoutString, String layoutData);

  E getConstraints(ComponentWidget comp);
  void addLayoutComponent(ComponentWidget pComponent, E pConstraints);
  void removeLayoutComponent(ComponentWidget pComponent);
  void updateLayoutData(String layoutData);
  void updateLayoutString(String layoutString);
  Widget getWidget();
}
