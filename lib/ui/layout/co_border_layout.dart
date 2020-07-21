import 'package:flutter/material.dart';
import 'widgets/co_border_layout_constraint.dart';
import '../container/i_container.dart';
import '../component/component.dart';
import '../component/i_component.dart';
import 'widgets/co_border_layout_widget.dart';
import 'co_layout.dart';

class CoBorderLayout extends CoLayout<CoBorderLayoutConstraints> {
  Key key = UniqueKey();

  /// the north component.
  Component _north;

  /// the south component.
  Component _south;

  /// the east component.
  Component _east;

  /// the west component.
  Component _west;

  /// the center component. */
  Component _center;

  CoBorderLayout(Key key) : super(key);

  CoBorderLayout.fromLayoutString(
      IContainer pContainer, String layoutString, String layoutData)
      : super.fromLayoutString(pContainer, layoutString, layoutData) {
    updateLayoutString(layoutString);
  }

  @override
  void updateLayoutString(String layoutString) {
    super.updateLayoutString(layoutString);
    parseFromString(layoutString);
  }

  void removeLayoutComponent(IComponent pComponent) {
    if (_center != null &&
        pComponent.componentId.toString() == _center.componentId.toString()) {
      _center = null;
    } else if (_north != null &&
        pComponent.componentId.toString() == _north.componentId.toString()) {
      _north = null;
    } else if (_south != null &&
        pComponent.componentId.toString() == _south.componentId.toString()) {
      _south = null;
    } else if (_east != null &&
        pComponent.componentId.toString() == _east.componentId.toString()) {
      _east = null;
    } else if (_west != null &&
        pComponent.componentId.toString() == _west.componentId.toString()) {
      _west = null;
    }
  }

  void addLayoutComponent(
      IComponent pComponent, CoBorderLayoutConstraints pConstraints) {
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

  CoBorderLayoutConstraints getConstraints(IComponent comp) {
    if (comp?.componentId.toString() == _center?.componentId.toString()) {
      return CoBorderLayoutConstraints.Center;
    } else if (comp?.componentId.toString() == _north?.componentId.toString()) {
      return CoBorderLayoutConstraints.North;
    } else if (comp?.componentId.toString() == _south?.componentId.toString()) {
      return CoBorderLayoutConstraints.South;
    } else if (comp?.componentId.toString() == _west?.componentId.toString()) {
      return CoBorderLayoutConstraints.West;
    } else if (comp?.componentId.toString() == _east?.componentId.toString()) {
      return CoBorderLayoutConstraints.East;
    }
    return null;
  }

  Widget getWidget() {
    List<CoBorderLayoutId> children = new List<CoBorderLayoutId>();

    if (_center != null && _center.isVisible) {
      children.add(new CoBorderLayoutId(
          child: _center.getWidget(),
          pConstraints: CoBorderLayoutConstraintData(
              CoBorderLayoutConstraints.Center, _center)));
    }

    if (_north != null && _north.isVisible) {
      children.add(new CoBorderLayoutId(
          child: _north.getWidget(),
          pConstraints: CoBorderLayoutConstraintData(
              CoBorderLayoutConstraints.North, _north)));
    }

    if (_south != null && _south.isVisible) {
      children.add(new CoBorderLayoutId(
          child: _south.getWidget(),
          pConstraints: CoBorderLayoutConstraintData(
              CoBorderLayoutConstraints.South, _south)));
    }

    if (_west != null && _west.isVisible) {
      children.add(new CoBorderLayoutId(
          child: _west.getWidget(),
          pConstraints: CoBorderLayoutConstraintData(
              CoBorderLayoutConstraints.West, _west)));
    }

    if (_east != null && _east.isVisible) {
      children.add(new CoBorderLayoutId(
          child: _east.getWidget(),
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
