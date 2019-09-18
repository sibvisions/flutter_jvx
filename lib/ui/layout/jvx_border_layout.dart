import 'package:flutter/material.dart';
import '../component/jvx_component.dart';
import '../component/i_component.dart';
import 'widgets/jvx_border_layout.dart';
import 'jvx_layout.dart';

class JVxBorderLayout extends JVxLayout<JVxBorderLayoutConstraints> {
  Key key = UniqueKey();
  /// the north component.
  JVxComponent _north;
  /// the south component.
  JVxComponent _south;
  /// the east component.
  JVxComponent _east;
  /// the west component.
  JVxComponent _west;
  /// the center component. */
  JVxComponent _center;

  JVxBorderLayout();

  JVxBorderLayout.fromLayoutString(String layoutString, String layoutData) {
    parseFromString(layoutString);
  }

  void removeLayoutComponent(IComponent pComponent) {
      if (_center!=null && pComponent.componentId.toString() == _center.componentId.toString())
      {
        _center = null;
      }
      else if (_north!=null && pComponent.componentId.toString() == _north.componentId.toString())
      {
        _north = null;
      }
      else if (_south!=null && pComponent.componentId.toString() == _south.componentId.toString())
      {
        _south = null;
      }
      else if (_east!=null && pComponent.componentId.toString() == _east.componentId.toString())
      {
        _east = null;
      }
      else if (_west!=null && pComponent.componentId.toString() == _west.componentId.toString())
      {
        _west = null;
      }
  }

  void addLayoutComponent(IComponent pComponent, JVxBorderLayoutConstraints pConstraints)
  {
    if (pConstraints == null || pConstraints == JVxBorderLayoutConstraints.Center)
    {
      _center = pComponent;
    }
    else if (pConstraints == JVxBorderLayoutConstraints.North)
    {
      _north = pComponent;
    }
    else if (pConstraints == JVxBorderLayoutConstraints.South)
    {
      _south = pComponent;
    }
    else if (pConstraints == JVxBorderLayoutConstraints.East)
    {
      _east = pComponent;
    }
    else if (pConstraints == JVxBorderLayoutConstraints.West)
    {
      _west = pComponent;
    }
    else
    {
      throw new ArgumentError("cannot add to layout: unknown constraint: " + pConstraints.toString());
    }
  }

  JVxBorderLayoutConstraints getConstraints(IComponent comp)
  {
    if (comp?.componentId.toString() == _center?.componentId.toString())
    {
      return JVxBorderLayoutConstraints.Center;
    }
    else if (comp?.componentId.toString() == _north?.componentId.toString())
    {
      return JVxBorderLayoutConstraints.North;
    }
    else if (comp?.componentId.toString() == _south?.componentId.toString())
    {
      return JVxBorderLayoutConstraints.South;
    }
    else if (comp?.componentId.toString() == _west?.componentId.toString())
    {
      return JVxBorderLayoutConstraints.West;
    }
    else if (comp?.componentId.toString() == _east?.componentId.toString())
    {
      return JVxBorderLayoutConstraints.East;
    }
    return null;
  }

  Widget getWidget() {
    List<JVxBorderLayoutId> children = new List<JVxBorderLayoutId>();

    if (_center!=null && _center.isVisible) {
      children.add(new JVxBorderLayoutId(child: _center.getWidget(), pConstraints: JVxBorderLayoutConstraints.Center));
    }

    if (_north!=null && _north.isVisible) {
      children.add(new JVxBorderLayoutId(child: _north.getWidget(), pConstraints: JVxBorderLayoutConstraints.North));
    }

    if (_south!=null && _south.isVisible) {
      children.add(new JVxBorderLayoutId(child: _south.getWidget(), pConstraints: JVxBorderLayoutConstraints.South));
    }

    if (_west!=null && _west.isVisible) {
      children.add(new JVxBorderLayoutId(child: _west.getWidget(), pConstraints: JVxBorderLayoutConstraints.West));
    }

    if (_east!=null && _east.isVisible) {
      children.add(new JVxBorderLayoutId(child: _east.getWidget(), pConstraints: JVxBorderLayoutConstraints.East));
    }

    return new JVxBorderLayoutWidget(
      key: key,
      insMargin: margins,
      iHorizontalGap: horizontalGap,
      iVerticalGap: verticalGap,
      children: children
    );
  }
}