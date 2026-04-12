/*
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:collection';

import 'package:flutter/widgets.dart';

import '../model/layout/gaps.dart';
import '../model/layout/layout_data.dart';
import '../model/layout/layout_position.dart';
import '../util/i_clonable.dart';
import 'i_layout.dart';

/// The BorderLayout allows the positioning of container in 5 different Positions.
/// North, East, West, South and Center.
/// North and South are above/underneath West, Center and East
/// East and West are left/right of center.
class BorderLayout extends ILayout implements ICloneable {
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

  /// The modifier with which to scale the layout.
  final double scaling;

  /// The original layout string.
  final String layoutString;

  /// Gaps between the components
  late final Gaps gaps;

  /// Map of all positions of the children.
  final Map<String, LayoutPosition> _positions = HashMap<String, LayoutPosition>();

  /// [LayoutData] of container this layout belongs to.
  late LayoutData _parent;

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
  BorderLayout({
    required this.layoutString,
    required this.scaling
  }) {
    List<String> layoutDef = layoutString.split(",");

    /// [1] = top margin in px (double)
    /// [2] = left margin in px (double)
    /// [3] = bottom margin in px (double)
    /// [4] = right margin in px (double)
    /// [5] = horizontal gap in px (int)
    /// [6] = vertical gap in px (int)
    margins = ILayout.marginsFromList(marginList: layoutDef.sublist(1, 5), scaling: scaling);
    gaps = Gaps.createFromList(gapsList: layoutDef.sublist(5, 7), scaling: scaling);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Makes a deep copy of this [BorderLayout].
  @override
  BorderLayout clone() {
    return BorderLayout(layoutString: layoutString, scaling: scaling);
  }

  @override
  void calculateLayout(LayoutData parent, List<LayoutData> children) {
    // Clear constraint map.
    _positions.clear();
    _parent = parent;

    String? compConst;

    for (int i = 0; i < children.length; i++) {
      compConst = children[i].constraints?.toUpperCase();

      if (compConst != null) {
        if (NORTH == compConst) {
          _childNorth = children[i];
        }
        else if (SOUTH == compConst) {
          _childSouth = children[i];
        }
        else if (WEST == compConst) {
          _childWest = children[i];
        }
        else if (EAST == compConst) {
          _childEast = children[i];
        }
        else if (CENTER == compConst) {
          _childCenter = children[i];
        }
      }
    }
    // How much size would we want? -> Preferred
    Size preferredSize = _preferredLayoutSize();

    parent.calculatedSize = preferredSize;

    double x = margins.left;
    double y = margins.top;
    double width = preferredSize.width;
    double height = preferredSize.height;

    // If parent has forced this into a size, cant exceed these values.
    if (parent.hasPosition) {
      width = parent.layoutPosition!.width;
      height = parent.layoutPosition!.height;
    }

    width = width - x - margins.right - parent.insets.horizontal;
    height = height - y - margins.bottom - parent.insets.vertical;

    if (_childNorth != null) {
      Size bestSize = _childNorth!.bestSize;

      _childNorth!.layoutPosition = LayoutPosition(left: x, top: y, width: width, height: bestSize.height);

      y += bestSize.height + gaps.verticalGap;
      height -= bestSize.height + gaps.verticalGap;
    }

    if (_childSouth != null) {
      Size bestSize = _childSouth!.bestSize;

      _childSouth!.layoutPosition =
          LayoutPosition(left: x, top: y + height - bestSize.height, width: width, height: bestSize.height);

      height -= bestSize.height + gaps.verticalGap;
    }

    if (_childWest != null) {
      Size bestSize = _childWest!.bestSize;

      _childWest!.layoutPosition = LayoutPosition(left: x, top: y, width: bestSize.width, height: height);

      x += bestSize.width + gaps.horizontalGap;
      width -= bestSize.width + gaps.horizontalGap;
    }

    if (_childEast != null) {
      Size bestSize = _childEast!.bestSize;

      _childEast!.layoutPosition =
          LayoutPosition(left: x + width - bestSize.width, top: y, width: bestSize.width, height: height);

      width -= bestSize.width + gaps.horizontalGap;
    }

    if (_childCenter != null) {
      _childCenter!.layoutPosition = LayoutPosition(left: x, top: y, width: width, height: height);
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns the preferred layout size
  Size _preferredLayoutSize() {
    if (_parent.hasPreferredSize) {
      return _parent.preferredSize!;
    } else {
      double width = 0;
      double height = 0;

      double maxWidth = 0;
      double maxHeight = 0;
      if (_childNorth != null && (_childNorth!.hasPreferredSize || _childNorth!.hasCalculatedSize)) {
        Size size = _childNorth!.bestSize;

        maxWidth = size.width;
        height += size.height + gaps.verticalGap;
      }
      if (_childSouth != null && (_childSouth!.hasPreferredSize || _childSouth!.hasCalculatedSize)) {
        Size size = _childSouth!.bestSize;

        if (size.width > maxWidth) {
          maxWidth = size.width;
        }
        height += size.height + gaps.verticalGap;
      }
      if (_childEast != null && (_childEast!.hasPreferredSize || _childEast!.hasCalculatedSize)) {
        Size size = _childEast!.bestSize;

        maxHeight = size.height;
        width += size.width + gaps.horizontalGap;
      }
      if (_childWest != null && (_childWest!.hasPreferredSize || _childWest!.hasCalculatedSize)) {
        Size size = _childWest!.bestSize;

        if (size.height > maxHeight) {
          maxHeight = size.height;
        }
        width += size.width + gaps.horizontalGap;
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

      return Size(
        width + margins.horizontal + _parent.insets.horizontal,
        height + margins.vertical + _parent.insets.vertical,
      );
    }
  }
}
