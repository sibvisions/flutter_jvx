import 'dart:collection';

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

  /// The original layout string.
  final String layoutString;

  /// The horizontal gap between components.
  int iHorizontalGap = 0;

  /// The vertical gap between components.
  int iVerticalGap = 0;

  /// The layout margins.
  EdgeInsets eiMargins = const EdgeInsets.all(0);

  /// Map of all positions of the children.
  final Map<String, LayoutPosition> _positions = HashMap<String, LayoutPosition>();

  /// [LayoutData] of container this layout belongs to.
  late LayoutData pParent;

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
  BorderLayout({required this.layoutString}) {
    _updateValuesFromString(layoutString);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  HashMap<String, LayoutData> calculateLayout(LayoutData pParent, List<LayoutData> pChildren) {
    // Clear constraint map.
    _positions.clear();
    this.pParent = pParent;

    _childNorth = pChildren.firstWhereOrNull((element) => NORTH == element.constraints?.toUpperCase());
    _childSouth = pChildren.firstWhereOrNull((element) => SOUTH == element.constraints?.toUpperCase());
    _childEast = pChildren.firstWhereOrNull((element) => EAST == element.constraints?.toUpperCase());
    _childWest = pChildren.firstWhereOrNull((element) => WEST == element.constraints?.toUpperCase());
    _childCenter = pChildren.firstWhereOrNull((element) => CENTER == element.constraints?.toUpperCase());

    // How much size would we want? -> Preferred
    Size preferredSize = _preferredLayoutSize();

    double x = pParent.insets!.left + eiMargins.left;
    double y = pParent.insets!.top + eiMargins.top;
    double width = preferredSize.width - x - pParent.insets!.right + eiMargins.right;
    double height = preferredSize.height - y - pParent.insets!.bottom + eiMargins.bottom;

    // If parent has forced this into a size, cant exceed these values.
    if (!pParent.hasPreferredSize && pParent.hasCalculatedSize && pParent.hasPosition) {
      width = pParent.layoutPosition!.width - x - pParent.insets!.right + eiMargins.right;
      height = pParent.layoutPosition!.height - y - pParent.insets!.bottom + eiMargins.bottom;
    } else if (!pParent.hasCalculatedSize) {
      pParent.calculatedSize = preferredSize;
    }

    HashMap<String, LayoutData> returnMap = HashMap<String, LayoutData>();

    if (_childNorth != null) {
      Size bestSize = _childNorth!.bestSize;

      ILayout.markForRedrawIfNeeded(_childNorth!, Size.fromWidth(width));

      _childNorth!.layoutPosition =
          LayoutPosition(left: x, top: y, width: width, height: bestSize.height, isComponentSize: true);

      y += bestSize.height + iVerticalGap;
      height -= bestSize.height + iVerticalGap;

      returnMap[_childNorth!.id] = _childNorth!;
    }

    if (_childSouth != null) {
        Size bestSize = _childSouth!.bestSize;

        ILayout.markForRedrawIfNeeded(_childSouth!, Size.fromWidth(width));

        _childSouth!.layoutPosition = LayoutPosition(
            left: x, top: y + height - bestSize.height, width: width, height: bestSize.height, isComponentSize: true);

        height -= bestSize.height + iVerticalGap;

        returnMap[_childSouth!.id] = _childSouth!;
    }

    if (_childWest != null) {
      Size bestSize = _childWest!.bestSize;

      ILayout.markForRedrawIfNeeded(_childWest!, Size.fromHeight(height));

      _childSouth!.layoutPosition =
          LayoutPosition(left: x, top: y, width: bestSize.width, height: height, isComponentSize: true);

      x += bestSize.width + iHorizontalGap;
      width -= bestSize.width + iHorizontalGap;

      returnMap[_childWest!.id] = _childWest!;
    }

    if (_childEast != null) {
      Size bestSize = _childEast!.bestSize;

      ILayout.markForRedrawIfNeeded(_childEast!, Size.fromHeight(height));

      _childEast!.layoutPosition = LayoutPosition(
          left: x + width - bestSize.width, top: y, width: bestSize.width, height: height, isComponentSize: true);

      width -= bestSize.width + iHorizontalGap;

      returnMap[_childEast!.id] = _childEast!;
    }

    if (_childCenter != null) {
      ILayout.markForRedrawIfNeeded(_childCenter!, Size.fromWidth(width));

      _childCenter!.layoutPosition =
          LayoutPosition(left: x, top: y, width: width, height: height, isComponentSize: true);

      returnMap[_childCenter!.id] = _childCenter!;
    }
    return returnMap;
  }

  /// Makes a deep copy of this [BorderLayout].
  @override
  BorderLayout clone() {
    return BorderLayout(layoutString: layoutString);
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
  void _updateValuesFromString(String layout) {
    List<String> parameter = layout.split(",");

    double top = double.parse(parameter[1]);
    double left = double.parse(parameter[2]);
    double bottom = double.parse(parameter[3]);
    double right = double.parse(parameter[4]);

    eiMargins = EdgeInsets.fromLTRB(left, top, right, bottom);
    iHorizontalGap = int.parse(parameter[5]);
    iVerticalGap = int.parse(parameter[6]);
  }

  /// Returns the preferred layout size
  Size _preferredLayoutSize() {
    if (pParent.hasPreferredSize) {
      return pParent.preferredSize!;
    } else if (pParent.hasCalculatedSize) {
      return pParent.calculatedSize!;
    } else {
      double width = 0;
      double height = 0;

      double maxWidth = 0;
      double maxHeight = 0;
      if (_childNorth != null && (_childNorth!.hasPreferredSize || _childNorth!.hasCalculatedSize)) {
        Size size = _childNorth!.bestSize;

        maxWidth = size.width;
        height += size.height + iVerticalGap;
      }
      if (_childSouth != null && (_childSouth!.hasPreferredSize || _childSouth!.hasCalculatedSize)) {
        Size size = _childSouth!.bestSize;

        if (size.width > maxWidth) {
          maxWidth = size.width;
        }
        height += size.height + iVerticalGap;
      }
      if (_childEast != null && (_childEast!.hasPreferredSize || _childEast!.hasCalculatedSize)) {
        Size size = _childEast!.bestSize;

        maxHeight = size.height;
        width += size.width + iHorizontalGap;
      }
      if (_childWest != null && (_childWest!.hasPreferredSize || _childWest!.hasCalculatedSize)) {
        Size size = _childWest!.bestSize;

        if (size.height > maxHeight) {
          maxHeight = size.height;
        }
        width += size.width + iHorizontalGap;
      }
      if (_childCenter != null && (_childCenter!.hasPreferredSize || _childCenter!.hasCalculatedSize)) {
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

      return Size(width + eiMargins.left + eiMargins.right, height + eiMargins.top + eiMargins.bottom);
    }
  }
}
