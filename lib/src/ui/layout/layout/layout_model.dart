import 'package:flutter/material.dart';

import '../../component/component_widget.dart';
import '../../container/co_container_widget.dart';
import 'i_layout.dart';

class LayoutModel<E> extends ChangeNotifier implements ILayoutModel<E> {
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

  @override
  bool get isMaximumSizeSet => maximumSize != null;

  @override
  bool get isMinimumSizeSet => minimumSize != null;

  @override
  bool get isPreferredSizeSet => preferredSize != null;

  @override
  void addLayoutComponent(ComponentWidget pComponent, E pConstraint) {
    layoutConstraints.putIfAbsent(pComponent, () => pConstraint);

    notifyListeners();
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

    notifyListeners();
  }

  @override
  void updateLayoutData(String layoutData) {
    rawLayoutData = layoutData;

    notifyListeners();
  }

  @override
  void updateLayoutString(String layoutString) {
    rawLayoutString = layoutString;

    notifyListeners();
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
}
