import 'package:flutter/material.dart';

import '../../component/component_widget.dart';
import '../../container/co_container_widget.dart';
import 'layout_model.dart';

enum LayoutState { DIRTY, RENDERED }

abstract class ILayoutModel<E> {
  LayoutState layoutState = LayoutState.RENDERED;

  Map<ComponentWidget, E> layoutConstraints = <ComponentWidget, E>{};

  EdgeInsets margins = EdgeInsets.zero;

  int horizontalGap = 0;

  int verticalGap = 0;

  CoContainerWidget? container;

  Size? preferredSize;
  Size? minimumSize;
  Size? maximumSize;

  Map<BoxConstraints, Size> layoutMaximumSize = Map<BoxConstraints, Size>();
  Map<BoxConstraints, Size> layoutMinimumSize = Map<BoxConstraints, Size>();
  Map<BoxConstraints, Size> layoutPreferredSize = Map<BoxConstraints, Size>();

  // Size? layoutPreferredSize;
  // Size? layoutMinimumSize;
  // Size? layoutMaximumSize;

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
  // void onChildVisibilityChange();
  void markNeedsRebuild();
  void performRebuild();
}
