import 'package:flutter/material.dart';
import 'interfaces/component_data.dart';
import '../layouts/jvx_border_layout.dart';

class BorderLayoutData implements ComponentData {
  /// the layout margins. */
  EdgeInsets _insMargins = EdgeInsets.zero;
  EdgeInsets get getMargins {
    return _insMargins;
  }
  set setMargins(EdgeInsets pMargins) {
    _insMargins = pMargins;
  }

  /// the horizontal gap between components.
  int	_iHorizontalGap;
  int get getHorizontalGap {
    return _iHorizontalGap;
  }
  set setHorizontalGap(int pGap) {
    _iHorizontalGap = pGap;
  }
  /// the vertical gap between components.
  int	_iVerticalGap;
  int get getVerticalGap {
    return _iVerticalGap;
  }
  set setVerticalGap(int pGap) {
    _iVerticalGap = pGap;
  }

  /// the north component.
  Widget _north;
  /// the south component.
  Widget _south;
  /// the east component.
  Widget _east;
  /// the west component.
  Widget _west;
  /// the center component. */
  Widget _center;

  BorderLayoutData();

  BorderLayoutData.fromGap(int pHorizontalGap, int pVerticalGap) {
    _iHorizontalGap = pHorizontalGap;
    _iVerticalGap = pVerticalGap;
  }

  void removeLayoutComponent(Widget pComponent) {
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

  void addLayoutComponent(Widget pComponent, BorderLayoutConstraints pConstraints)
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

  BorderLayoutConstraints getConstraints(Widget comp)
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

  Widget getWidget(Key key) {
    List<JVxBorderLayoutId> children = new List<JVxBorderLayoutId>();

    if (_center!=null) {
      children.add(_center);
    }

    if (_north!=null) {
      children.add(_north);
    }

    if (_south!=null) {
      children.add(_south);
    }

    if (_west!=null) {
      children.add(_west);
    }

    if (_east!=null) {
      children.add(_east);
    }

    return new JVxBorderLayout(
      key: key,
      insMargin: _insMargins,
      iHorizontalGap: _iHorizontalGap,
      iVerticalGap: _iVerticalGap,
      children: children
    );
  }
}