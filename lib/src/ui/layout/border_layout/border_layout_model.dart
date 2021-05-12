import 'package:flutter/cupertino.dart';
import 'package:flutterclient/src/ui/component/component_widget.dart';
import 'package:flutterclient/src/ui/container/co_container_widget.dart';
import 'package:flutterclient/src/ui/layout/co_layout.dart';
import 'package:flutterclient/src/ui/layout/widgets/co_border_layout_constraint.dart';

class BorderLayoutModel extends ChangeNotifier
    with CoLayout<CoBorderLayoutConstraints> {
  ComponentWidget? north;
  ComponentWidget? south;
  ComponentWidget? east;
  ComponentWidget? west;
  ComponentWidget? center;

  BorderLayoutModel();

  BorderLayoutModel.fromLayoutString(
      CoContainerWidget container, String layoutString, String? layoutData) {
    updateLayoutString(layoutString);
    super.container = container;
  }

  void addLayoutComponent(
      ComponentWidget componentWidget, CoBorderLayoutConstraints constraints) {
    switch (constraints) {
      case CoBorderLayoutConstraints.North:
        north = componentWidget;
        break;
      case CoBorderLayoutConstraints.South:
        south = componentWidget;
        break;
      case CoBorderLayoutConstraints.West:
        west = componentWidget;
        break;
      case CoBorderLayoutConstraints.East:
        east = componentWidget;
        break;
      case CoBorderLayoutConstraints.Center:
        center = componentWidget;
        break;
    }

    notifyListeners();
  }

  void removeLayoutComponent(ComponentWidget componentWidget) {
    if (center == componentWidget) {
      center = null;
    } else if (north == componentWidget) {
      north = null;
    } else if (south == componentWidget) {
      south = null;
    } else if (west == componentWidget) {
      west = null;
    } else if (east == componentWidget) {
      east = null;
    }

    notifyListeners();
  }

  @override
  void updateLayoutString(String layoutString) {
    super.updateLayoutString(layoutString);
    parseFromString(layoutString);
  }

  @override
  CoBorderLayoutConstraints? getConstraints(ComponentWidget comp) {
    if (comp.componentModel.componentId == center?.componentModel.componentId) {
      return CoBorderLayoutConstraints.Center;
    } else if (comp.componentModel.componentId ==
        north?.componentModel.componentId) {
      return CoBorderLayoutConstraints.North;
    } else if (comp.componentModel.componentId ==
        south?.componentModel.componentId) {
      return CoBorderLayoutConstraints.South;
    } else if (comp.componentModel.componentId ==
        west?.componentModel.componentId) {
      return CoBorderLayoutConstraints.West;
    } else if (comp.componentModel.componentId ==
        east?.componentModel.componentId) {
      return CoBorderLayoutConstraints.East;
    }

    try {
      CoBorderLayoutConstraints constraints =
          getBorderLayoutConstraintsFromString(comp.componentModel.constraints);

      return constraints;
    } on Exception {
      return null;
    }
  }
}
