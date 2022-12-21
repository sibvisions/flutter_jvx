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
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import '../model/layout/gaps.dart';
import '../model/layout/layout_data.dart';
import '../model/layout/layout_position.dart';
import '../model/layout/margins.dart';
import '../util/i_clonable.dart';
import 'i_layout.dart';

/// The BorderLayout allows the positioning of container in 5 different Positions.
/// North, East, West, South and Center.
/// North and South are above/underneath West, Center and East
/// East and West are left/right of center.
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

  /// The modifier with which to scale the layout.
  final double scaling;

  /// The original layout string.
  final String layoutString;

  /// Margins of the BorderLayout
  late final Margins margins;

  /// Gaps between the components
  late final Gaps gaps;

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
  BorderLayout({required this.layoutString, required this.scaling}) {
    _updateValuesFromString(layoutString);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void calculateLayout(LayoutData pParent, List<LayoutData> pChildren) {
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

    pParent.calculatedSize = preferredSize;

    double x = pParent.insets.left + margins.marginLeft;
    double y = pParent.insets.top + margins.marginTop;
    double width = preferredSize.width - x - pParent.insets.right + margins.marginRight;
    double height = preferredSize.height - y - pParent.insets.bottom + margins.marginBottom;

    // If parent has forced this into a size, cant exceed these values.
    if (pParent.hasPosition) {
      if (pParent.layoutPosition!.isComponentSize) {
        width = pParent.layoutPosition!.width - x - pParent.insets.right - margins.marginRight;
        height = pParent.layoutPosition!.height - y - pParent.insets.bottom - margins.marginBottom;
      } else {
        width =
            max(pParent.layoutPosition!.width, preferredSize.width) - x - pParent.insets.right - margins.marginRight;
        height = max(pParent.layoutPosition!.height, preferredSize.height) -
            y -
            pParent.insets.bottom -
            margins.marginBottom;
      }
    }

    if (_childNorth != null) {
      Size bestSize = _childNorth!.bestSize;

      _childNorth!.layoutPosition =
          LayoutPosition(left: x, top: y, width: width, height: bestSize.height, isComponentSize: true);

      y += bestSize.height + gaps.verticalGap;
      height -= bestSize.height + gaps.verticalGap;
    }

    if (_childSouth != null) {
      Size bestSize = _childSouth!.bestSize;

      _childSouth!.layoutPosition = LayoutPosition(
          left: x, top: y + height - bestSize.height, width: width, height: bestSize.height, isComponentSize: true);

      height -= bestSize.height + gaps.verticalGap;
    }

    if (_childWest != null) {
      Size bestSize = _childWest!.bestSize;

      _childWest!.layoutPosition =
          LayoutPosition(left: x, top: y, width: bestSize.width, height: height, isComponentSize: true);

      x += bestSize.width + gaps.horizontalGap;
      width -= bestSize.width + gaps.horizontalGap;
    }

    if (_childEast != null) {
      Size bestSize = _childEast!.bestSize;

      _childEast!.layoutPosition = LayoutPosition(
          left: x + width - bestSize.width, top: y, width: bestSize.width, height: height, isComponentSize: true);

      width -= bestSize.width + gaps.horizontalGap;
    }

    if (_childCenter != null) {
      _childCenter!.layoutPosition =
          LayoutPosition(left: x, top: y, width: width, height: height, isComponentSize: true);
    }
  }

  /// Makes a deep copy of this [BorderLayout].
  @override
  BorderLayout clone() {
    return BorderLayout(layoutString: layoutString, scaling: scaling);
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

    margins = Margins.fromList(marginList: parameter.sublist(1, 5), scaling: scaling);
    gaps = Gaps.createFromList(gapsList: parameter.sublist(5, 7), scaling: scaling);
  }

  /// Returns the preferred layout size
  Size _preferredLayoutSize() {
    if (pParent.hasPreferredSize) {
      return pParent.preferredSize!;
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

      return Size(width + margins.marginLeft + margins.marginRight, height + margins.marginTop + margins.marginBottom);
    }
  }
}
