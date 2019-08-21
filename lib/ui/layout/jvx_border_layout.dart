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

  JVxBorderLayout.fromGap(int pHorizontalGap, int pVerticalGap) {
    horizontalGap = pHorizontalGap;
    verticalGap = pVerticalGap;
  }

  JVxBorderLayout.fromLayoutString(String layoutString) {
    List<String> parameter = layoutString?.split(",");
    
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

  void addLayoutComponent(JVxComponent pComponent, JVxBorderLayoutConstraints pConstraints)
  {
    if (pConstraints == null || pConstraints == JVxBorderLayoutConstraints.CENTER)
    {
      _center = pComponent;
    }
    else if (pConstraints == JVxBorderLayoutConstraints.NORTH)
    {
      _north = pComponent;
    }
    else if (pConstraints == JVxBorderLayoutConstraints.SOUTH)
    {
      _south = pComponent;
    }
    else if (pConstraints == JVxBorderLayoutConstraints.EAST)
    {
      _east = pComponent;
    }
    else if (pConstraints == JVxBorderLayoutConstraints.WEST)
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
    if (comp == _center)
    {
      return JVxBorderLayoutConstraints.CENTER;
    }
    else if (comp == _north)
    {
      return JVxBorderLayoutConstraints.NORTH;
    }
    else if (comp == _south)
    {
      return JVxBorderLayoutConstraints.SOUTH;
    }
    else if (comp == _west)
    {
      return JVxBorderLayoutConstraints.WEST;
    }
    else if (comp == _east)
    {
      return JVxBorderLayoutConstraints.EAST;
    }
    return null;
  }

  Widget getWidget() {
    List<JVxBorderLayoutId> children = new List<JVxBorderLayoutId>();

    if (_center!=null && _center.isVisible) {
      children.add(new JVxBorderLayoutId(child: _center.getWidget(), pConstraints: JVxBorderLayoutConstraints.CENTER));
    }

    if (_north!=null && _north.isVisible) {
      children.add(new JVxBorderLayoutId(child: _north.getWidget(), pConstraints: JVxBorderLayoutConstraints.NORTH));
    }

    if (_south!=null && _south.isVisible) {
      children.add(new JVxBorderLayoutId(child: _south.getWidget(), pConstraints: JVxBorderLayoutConstraints.SOUTH));
    }

    if (_west!=null && _west.isVisible) {
      children.add(new JVxBorderLayoutId(child: _west.getWidget(), pConstraints: JVxBorderLayoutConstraints.WEST));
    }

    if (_east!=null && _east.isVisible) {
      children.add(new JVxBorderLayoutId(child: _east.getWidget(), pConstraints: JVxBorderLayoutConstraints.EAST));
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