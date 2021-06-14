import 'dart:developer';

import 'package:flutter/material.dart';

import '../../component/component_widget.dart';
import '../../container/co_container_widget.dart';
import 'i_layout_model.dart';

class LayoutModel<E> extends ChangeNotifier implements ILayoutModel<E> {
  @override
  LayoutState layoutState = LayoutState.DIRTY;

  @override
  CoContainerWidget? container;

  @override
  int horizontalGap = 0;

  @override
  Map<ComponentWidget, E> layoutConstraints = <ComponentWidget, E>{};

  @override
  EdgeInsets margins = EdgeInsets.zero;

  @override
  Size? maximumSize;

  @override
  Size? minimumSize;

  @override
  Size? preferredSize;

  @override
  int verticalGap = 0;

  String rawLayoutData = '';

  String rawLayoutString = '';

  Map<String, Key> keys = <String, Key>{};

  @override
  Size? layoutMaximumSize;

  @override
  Size? layoutMinimumSize;

  @override
  Size? layoutPreferredSize;

  @override
  bool get isMaximumSizeSet => maximumSize != null;

  @override
  bool get isMinimumSizeSet => minimumSize != null;

  @override
  bool get isPreferredSizeSet => preferredSize != null;

  Key? getKeyByComponentId(String componentId) {
    return keys[componentId];
  }

  Key? createKey(String componentId) {
    keys[componentId] = GlobalKey(debugLabel: componentId);
    return keys[componentId];
  }

  @override
  void addLayoutComponent(ComponentWidget pComponent, E pConstraint) {
    layoutConstraints.putIfAbsent(pComponent, () => pConstraint);

    markNeedsRebuild();
  }

  @override
  E? getConstraints(ComponentWidget comp) {
    return layoutConstraints[comp];
  }

  @override
  void removeLayoutComponent(ComponentWidget pComponent) {
    layoutConstraints.removeWhere((ComponentWidget comp, E constraint) =>
        comp.componentModel.componentId ==
        pComponent.componentModel.componentId);

    markNeedsRebuild();
  }

  @override
  void updateLayoutData(String layoutData) {
    rawLayoutData = layoutData;

    markNeedsRebuild();
  }

  @override
  void updateLayoutString(String layoutString) {
    rawLayoutString = layoutString;

    markNeedsRebuild();
  }

  void parseFromString(String layout) {
    List<String> parameter = layout.split(",");

    double top = double.parse(parameter[1]);
    double left = double.parse(parameter[2]);
    double bottom = double.parse(parameter[3]);
    double right = double.parse(parameter[4]);

    margins = EdgeInsets.fromLTRB(left, top, right, bottom);
    horizontalGap = int.parse(parameter[5]);
    verticalGap = int.parse(parameter[6]);
  }

  static String? getLayoutName(String layoutString) {
    List<String> parameter = layoutString.split(",");
    if (parameter.length > 0) {
      return parameter[0];
    }

    return null;
  }

  @override
  void onChildVisibilityChange() {
    markNeedsRebuild();
  }

  @override
  void markNeedsRebuild() {
    layoutState = LayoutState.DIRTY;
  }

  @override
  void performRebuild() {
    if (layoutState == LayoutState.DIRTY) {
      log('Performing rebuild for ${getLayoutName(rawLayoutString)}');
      notifyListeners();
    }
  }
}
