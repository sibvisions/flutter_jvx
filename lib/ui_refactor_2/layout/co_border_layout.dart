import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/ui_refactor_2/component/component_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/container/co_container_widget.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/widgets/co_border_layout_constraint.dart';
import 'package:jvx_flutterclient/ui_refactor_2/layout/widgets/co_border_layout_widget.dart';
import 'package:universal_html/prefer_sdk/html.dart';
import 'co_layout.dart';

class CoBorderLayout extends CoLayout<CoBorderLayoutConstraints> {
  Key key = UniqueKey();

  /// the north component.
  ComponentWidget _north;

  /// the south component.
  ComponentWidget _south;

  /// the east component.
  ComponentWidget _east;

  /// the west component.
  ComponentWidget _west;

  /// the center component. */
  ComponentWidget _center;

  CoBorderLayout(Key key) : super(key);

  CoBorderLayout.fromLayoutString(
      CoContainerWidget pContainer, String layoutString, String layoutData)
      : super.fromLayoutString(pContainer, layoutString, layoutData) {
    updateLayoutString(layoutString);
  }

  @override
  void updateLayoutString(String layoutString) {
    super.updateLayoutString(layoutString);
    parseFromString(layoutString);
  }

  void removeLayoutComponent(ComponentWidget pComponent) {
    if (_center != null &&
        pComponent.componentModel.componentId ==
            _center.componentModel.componentId) {
      _center = null;
    } else if (_north != null &&
        pComponent.componentModel.componentId ==
            _north.componentModel.componentId) {
      _north = null;
    } else if (_south != null &&
        pComponent.componentModel.componentId ==
            _south.componentModel.componentId) {
      _south = null;
    } else if (_east != null &&
        pComponent.componentModel.componentId ==
            _east.componentModel.componentId) {
      _east = null;
    } else if (_west != null &&
        pComponent.componentModel.componentId ==
            _west.componentModel.componentId) {
      _west = null;
    }
  }

  void addLayoutComponent(
      ComponentWidget pComponent, CoBorderLayoutConstraints pConstraints) {
    if (pConstraints == null ||
        pConstraints == CoBorderLayoutConstraints.Center) {
      _center = pComponent;
    } else if (pConstraints == CoBorderLayoutConstraints.North) {
      _north = pComponent;
    } else if (pConstraints == CoBorderLayoutConstraints.South) {
      _south = pComponent;
    } else if (pConstraints == CoBorderLayoutConstraints.East) {
      _east = pComponent;
    } else if (pConstraints == CoBorderLayoutConstraints.West) {
      _west = pComponent;
    } else {
      throw new ArgumentError("cannot add to layout: unknown constraint: " +
          pConstraints.toString());
    }
  }

  CoBorderLayoutConstraints getConstraints(ComponentWidget comp) {
    if (comp?.componentModel?.componentId ==
        _center?.componentModel?.componentId) {
      return CoBorderLayoutConstraints.Center;
    } else if (comp?.componentModel?.componentId ==
        _north?.componentModel?.componentId) {
      return CoBorderLayoutConstraints.North;
    } else if (comp?.componentModel?.componentId ==
        _south?.componentModel?.componentId) {
      return CoBorderLayoutConstraints.South;
    } else if (comp?.componentModel?.componentId ==
        _west?.componentModel?.componentId) {
      return CoBorderLayoutConstraints.West;
    } else if (comp?.componentModel?.componentId ==
        _east?.componentModel?.componentId) {
      return CoBorderLayoutConstraints.East;
    }
    return null;
  }

  Widget getWidget() {
    List<CoBorderLayoutId> children = new List<CoBorderLayoutId>();

    if (_center != null && _center.componentModel.isVisible) {
      children.add(new CoBorderLayoutId(
          child: _center,
          pConstraints: CoBorderLayoutConstraintData(
              CoBorderLayoutConstraints.Center, _center)));
    }

    if (_north != null && _north.componentModel.isVisible) {
      children.add(new CoBorderLayoutId(
          child: _north,
          pConstraints: CoBorderLayoutConstraintData(
              CoBorderLayoutConstraints.North, _north)));
    }

    if (_south != null && _south.componentModel.isVisible) {
      children.add(new CoBorderLayoutId(
          child: _south,
          pConstraints: CoBorderLayoutConstraintData(
              CoBorderLayoutConstraints.South, _south)));
    }

    if (_west != null && _west.componentModel.isVisible) {
      children.add(new CoBorderLayoutId(
          child: _west,
          pConstraints: CoBorderLayoutConstraintData(
              CoBorderLayoutConstraints.West, _west)));
    }

    if (_east != null && _east.componentModel.isVisible) {
      children.add(new CoBorderLayoutId(
          child: _east,
          pConstraints: CoBorderLayoutConstraintData(
              CoBorderLayoutConstraints.East, _east)));
    }

    return Container(
        margin: this.margins,
        child: CoBorderLayoutWidget(
            key: key,
            container: container,
            insMargin: margins,
            iHorizontalGap: horizontalGap,
            iVerticalGap: verticalGap,
            children: children));
  }
}
