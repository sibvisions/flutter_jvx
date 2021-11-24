import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../util/extensions/list_extensions.dart';
import '../../util/i_clonable.dart';
import '../model/layout/layout_data.dart';
import '../model/layout/layout_position.dart';
import 'i_layout.dart';


/// The BorderLayout allows the positioning of container in 5 different Positions.
/// North, East, West, South and Center.
/// North and South are above/underneath West, Center and East
/// East and West are left/right of center.
///
/// \_\_\_\_\_\_\_ NORTH \_\_\_\_\_\_\_\_
/// |          |            |           |
/// |   WEST   |   CENTER   |    EAST   |
/// |          |            |           |
/// ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾ SOUTH ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
///
// Author: Martin Handsteiner, ported by Toni Heiss.
class BorderLayout implements ILayout, ICloneable {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The north layout constraint (top of container).
  static const String NORTH = "NORTH";

  /// The east layout constraint (right side of container). */
  static const String EAST = "EAST";

  /// The south layout constraint (bottom of container). */
  static const String SOUTH = "SOUTH";

  /// The west layout constraint (left side of container). */
  static const String WEST = "WEST";

  /// The center layout constraint (middle of container).
  static const String CENTER = "CENTER";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// the horizontal gap between components.
  int iHorizontalGap = 0;

  /// the vertical gap between components.
  int iVerticalGap = 0;

  /// the layout margins.
  EdgeInsets eiMargins = const EdgeInsets.all(0);

  /// Map of all positions of the children.
  final Map<String, LayoutPosition> _positions = HashMap<String, LayoutPosition>();

  /// [LayoutData] of container this layout belongs to.
  late LayoutData _parentData;

  /// Child with layout constraint [NORTH];
  LayoutData? _childNorth;

  /// Child with layout constraint [SOUTH];
  LayoutData? _childSouth;

  /// Child with layout constraint [EAST];
  LayoutData? _childEast;

  /// Child with layout constraint [WEST];
  LayoutData? _childWest;

  /// Child with layout constraint [CENTER];
  LayoutData? _childCenter;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes a [BorderLayout].
  BorderLayout(String pLayout) {
    updateValuesFromString(pLayout);
  }

  BorderLayout.from(BorderLayout pLayout) {
    eiMargins = pLayout.eiMargins.copyWith();
    iVerticalGap = pLayout.iVerticalGap;
    iHorizontalGap = pLayout.iHorizontalGap;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, LayoutPosition> calculateLayout(LayoutData pParent) {
    // Clear constraint map.
    _positions.clear();

    _parentData = pParent;
    _childNorth   = _parentData.children!.firstWhereOrNull((element) => NORTH == element.constraints);
    _childSouth   = _parentData.children!.firstWhereOrNull((element) => SOUTH == element.constraints);
    _childEast    = _parentData.children!.firstWhereOrNull((element) => EAST  == element.constraints);
    _childWest    = _parentData.children!.firstWhereOrNull((element) => WEST  == element.constraints);
    _childCenter  = _parentData.children!.firstWhereOrNull((element) => NORTH == element.constraints);

    // How much size would we want? -> Preferred
    Size preferredSize = _preferredLayoutSize();
    double maxWidth = preferredSize.width;
    double maxHeight = preferredSize.height;

    double occupiedWidth = 0;
    double occupiedHeight = 0;

    // If parent has forced this into a size, cant exceed these values.
    if (_parentData.hasPosition)
    {
      maxWidth = _parentData.layoutPosition!.width - _parentData.insets!.left - _parentData.insets!.right;
      maxHeight = _parentData.layoutPosition!.height - _parentData.insets!.top - _parentData.insets!.bottom;
    }

    // Position north child.
    if (_childNorth != null)
    {
      double northHeight = _childNorth!.bestSize.height;
      
      if (northHeight > (maxHeight))
      {
        northHeight = (maxHeight); 
      }

      _positions[_childNorth!.id] = LayoutPosition(top: eiMargins.top, left: eiMargins.left, height: northHeight, width: maxWidth);

      occupiedHeight += northHeight + iVerticalGap;
    }
    
    // Position south child.
    if (_childSouth != null)
    {
      double southHeight = _childSouth!.bestSize.height;
      
      if (southHeight > (maxHeight - occupiedHeight))
      {
        southHeight = (maxHeight - occupiedHeight); 
      }

      _positions[_childNorth!.id] = LayoutPosition(top: eiMargins.top, left: eiMargins.left, height: southHeight, width: maxWidth);

      occupiedHeight += southHeight + iVerticalGap;
    }

    //parent.layoutData
    return _positions;
  }

  /// Makes a deep copy of this [BorderLayout].
  @override
  BorderLayout clone() {
    return BorderLayout.from(this);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Updates values of this [BorderLayout] to match data in this string.
  ///
  /// String has to be: BorderLayout,[1],[2],[3],[4],[5],[6]
  ///
  /// Where:
  ///
  /// [1] = top margin in px (double)
  ///
  /// [2] = left margin in px (double)
  ///
  /// [3] = bottom margin in px (double)
  ///
  /// [4] = right margin in px (double)
  ///
  /// [5] = horizontal gap in px (int)
  ///
  /// [6] = vertical gap in px (int)
  void updateValuesFromString(String layout) {
    List<String> parameter = layout.split(",");

    double top = double.parse(parameter[1]);
    double left = double.parse(parameter[2]);
    double bottom = double.parse(parameter[3]);
    double right = double.parse(parameter[4]);

    eiMargins = EdgeInsets.fromLTRB(left, top, right, bottom);
    iHorizontalGap = int.parse(parameter[5]);
    iVerticalGap = int.parse(parameter[6]);
  }

  Size _maximumLayoutSize() {
    if (_parentData.maxSize != null)
    {
      return _parentData.maxSize!;
    }
    return const Size(double.infinity, double.infinity);
  }

  Size _minimumLayoutSize() {
    if (_parentData.hasMinSize) {
      return _parentData.minSize!;
    } 
    else 
    {
      Size n = const Size(0, 0);
      if (_childNorth != null && _childNorth!.hasMinSize)
      {
        n = _childNorth!.bestMinSize;
      }
      Size e = const Size(0, 0);
      if (_childEast != null && _childEast!.hasMinSize)
      {
        e = _childEast!.bestMinSize;
      }
      Size s = const Size(0, 0);
      if (_childSouth != null && _childSouth!.hasMinSize)
      {
        s = _childSouth!.bestMinSize;
      }
      Size w = const Size(0, 0);
      if (_childWest != null && _childWest!.hasMinSize)
      {
        w = _childWest!.bestMinSize;
      }
      Size c = const Size(0, 0);
      if (_childCenter != null && _childCenter!.hasMinSize)
      {
        c = _childCenter!.bestMinSize;
      }

      return Size(max(max(n.width, s.width), w.width + c.width + e.width),
          max(max(w.height, e.height), c.height) + n.height + s.height);
    }
  }

  Size _preferredLayoutSize() {
    if (_parentData.hasPreferredSize) {
      return _parentData.preferredSize!;
    } 
    else
    {
      double width = 0;
      double height = 0;

      double maxWidth = 0;
      double maxHeight = 0;
      if (_childNorth != null && _childNorth!.hasPreferredSize) {
        Size size = _childNorth!.bestSize;

        maxWidth = size.width;
        height += size.height + iVerticalGap;
      }
      if (_childSouth != null && _childSouth!.hasPreferredSize) {
        Size size = _childSouth!.bestSize;

        if (size.width > maxWidth) {
          maxWidth = size.width;
        }
        height += size.height + iVerticalGap;
      }
      if (_childEast != null && _childEast!.hasPreferredSize) {
        Size size = _childEast!.bestSize;

        maxHeight = size.height;
        width += size.width + iHorizontalGap;
      }
      if (_childWest != null && _childWest!.hasPreferredSize) {
        Size size = _childWest!.bestSize;

        if (size.height > maxHeight) {
          maxHeight = size.height;
        }
        width += size.width + iHorizontalGap;
      }
      if (_childCenter != null && _childCenter!.hasPreferredSize) {
        Size size = _childCenter!.bestSize;
        if (size.height > maxHeight) {
          maxHeight = size.height;
        }
        width += size.width;
      }
      height += maxHeight;
      if (maxWidth > width) {
        width = maxWidth;
      }

      return Size(width + eiMargins.left + eiMargins.right,
          height + eiMargins.top + eiMargins.bottom);
    }
  }
}
