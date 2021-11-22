import 'package:flutter/material.dart';
import 'package:flutter_jvx/src/layout/i_layout.dart';
import 'package:flutter_jvx/src/models/layout/layout_data.dart';
import 'package:flutter_jvx/src/models/layout/layout_position.dart';
import 'package:flutter_jvx/src/util/i_clonable.dart';

import '../util/extensions/list_extensions.dart';

/// The BorderLayout allows the positioning of container in 5 different Positions.
/// North, East, West, South and Center.
/// North and South are above/underneath West, Center and East
/// East and West are left/right of center.
///
/// \_\_\_\_\_\_\_ NORTH \_\_\_\_\_\_\_\_
///
/// WEST \| CENTER \| EAST
///
/// ‾‾‾‾‾‾‾ SOUTH ‾‾‾‾‾‾‾‾
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
  List<LayoutPosition> calculateLayout(LayoutData pParent) {
    List<LayoutPosition> constraints = List.empty(growable: true);

    LayoutData? childNorth = pParent.children!.firstWhereOrNull((element) => NORTH == element.constraints);
    LayoutData? childSouth = pParent.children!.firstWhereOrNull((element) => SOUTH == element.constraints);
    LayoutData? childEast = pParent.children!.firstWhereOrNull((element) => EAST == element.constraints);
    LayoutData? childWest = pParent.children!.firstWhereOrNull((element) => WEST == element.constraints);
    LayoutData? childCenter = pParent.children!.firstWhereOrNull((element) => NORTH == element.constraints);

    //parent.layoutData
    return List.empty();
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
}
