import 'package:flutter/material.dart';
import '../component/jvx_component.dart';
import '../component/i_component.dart';
import 'jvx_border_layout.dart';
import 'layout.dart';

class BorderLayout extends Layout<BorderLayoutConstraints> {
  Key key;
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

  BorderLayout();

  BorderLayout.fromGap(int pHorizontalGap, int pVerticalGap) {
    horizontalGap = pHorizontalGap;
    verticalGap = pVerticalGap;
  }

  void removeLayoutComponent(JVxComponent pComponent) {
      if (pComponent == _center)
      {
        _center = null;
      }
      else if (pComponent == _north)
      {
        _north = null;
      }
      else if (pComponent == _south)
      {
        _south = null;
      }
      else if (pComponent == _east)
      {
        _east = null;
      }
      else if (pComponent == _west)
      {
        _west = null;
      }
  }

  void addLayoutComponent(JVxComponent pComponent, BorderLayoutConstraints pConstraints)
  {
    if (pConstraints == null || pConstraints == BorderLayoutConstraints.CENTER)
    {
      _center = pComponent;
    }
    else if (pConstraints == BorderLayoutConstraints.NORTH)
    {
      _north = pComponent;
    }
    else if (pConstraints == BorderLayoutConstraints.SOUTH)
    {
      _south = pComponent;
    }
    else if (pConstraints == BorderLayoutConstraints.EAST)
    {
      _east = pComponent;
    }
    else if (pConstraints == BorderLayoutConstraints.WEST)
    {
      _west = pComponent;
    }
    else
    {
      throw new ArgumentError("cannot add to layout: unknown constraint: " + pConstraints.toString());
    }
  }

  BorderLayoutConstraints getConstraints(IComponent comp)
  {
    if (comp == _center)
    {
      return BorderLayoutConstraints.CENTER;
    }
    else if (comp == _north)
    {
      return BorderLayoutConstraints.NORTH;
    }
    else if (comp == _south)
    {
      return BorderLayoutConstraints.SOUTH;
    }
    else if (comp == _west)
    {
      return BorderLayoutConstraints.WEST;
    }
    else if (comp == _east)
    {
      return BorderLayoutConstraints.EAST;
    }
    return null;
  }

  Widget getWidget() {
    List<JVxBorderLayoutId> children = new List<JVxBorderLayoutId>();

    if (_center!=null && _center.isVisible) {
      children.add(new JVxBorderLayoutId(child: _center.getWidget(), pConstraints: BorderLayoutConstraints.CENTER));
    }

    if (_north!=null && _north.isVisible) {
      children.add(new JVxBorderLayoutId(child: _north.getWidget(), pConstraints: BorderLayoutConstraints.NORTH));
    }

    if (_south!=null && _south.isVisible) {
      children.add(new JVxBorderLayoutId(child: _south.getWidget(), pConstraints: BorderLayoutConstraints.SOUTH));
    }

    if (_west!=null && _west.isVisible) {
      children.add(new JVxBorderLayoutId(child: _west.getWidget(), pConstraints: BorderLayoutConstraints.WEST));
    }

    if (_east!=null && _east.isVisible) {
      children.add(new JVxBorderLayoutId(child: _east.getWidget(), pConstraints: BorderLayoutConstraints.EAST));
    }

    return new JVxBorderLayout(
      key: key,
      insMargin: margins,
      iHorizontalGap: horizontalGap,
      iVerticalGap: verticalGap,
      children: children
    );
  }
}