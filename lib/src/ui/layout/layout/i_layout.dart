import 'package:flutter/material.dart';

import '../../component/component_widget.dart';
import '../../container/co_container_widget.dart';

abstract class ILayoutModel<E> {
  Map<ComponentWidget, E> layoutConstraints = <ComponentWidget, E>{};

  EdgeInsets margins = EdgeInsets.zero;

  int horizontalGap = 0;

  int verticalGap = 0;

  CoContainerWidget? container;

  Size? preferredSize;
  Size? minimumSize;
  Size? maximumSize;

  bool get isPreferredSizeSet;
  bool get isMinimumSizeSet;
  bool get isMaximumSizeSet;

  ILayoutModel.fromLayoutString(
      CoContainerWidget container, String layoutString, String layoutData);

  E? getConstraints(ComponentWidget comp);
  void addLayoutComponent(ComponentWidget pComponent, E pConstraints);
  void removeLayoutComponent(ComponentWidget pComponent);
  void updateLayoutData(String layoutData);
  void updateLayoutString(String layoutString);
}
