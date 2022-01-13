//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// VerticalAlignment
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

import 'package:flutter/cupertino.dart';

/// Possible Vertical Alignments (TOP=0, CENTER=1, BOTTOM=2, STRETCH=3)
enum VerticalAlignment { TOP, CENTER, BOTTOM, STRETCH }

extension VerticalAlignmentE on VerticalAlignment {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Parses [pAlignment] to [VerticalAlignment]
  static VerticalAlignment fromString(String pAlignment) {
    return VerticalAlignment.values[int.parse(pAlignment)];
  }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// HorizontalAlignment
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/// Possible Horizontal Alignments (LEFT=0, CENTER=1, RIGHT=2, STRETCH=3)
enum HorizontalAlignment { LEFT, CENTER, RIGHT, STRETCH }

extension HorizontalAlignmentE on HorizontalAlignment {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Parses [pAlignment] to [HorizontalAlignment]
  static HorizontalAlignment fromString(String pAlignment) {
    return HorizontalAlignment.values[int.parse(pAlignment)];
  }

  static TextAlign toTextAlign(HorizontalAlignment pAlignment) {
    switch (pAlignment) {
      case HorizontalAlignment.LEFT:
        return TextAlign.left;
      case HorizontalAlignment.CENTER:
        return TextAlign.center;
      case HorizontalAlignment.RIGHT:
        return TextAlign.right;
      case HorizontalAlignment.STRETCH:
        return TextAlign.justify;
    }
  }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Orientation
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/// Possible Orientation {HORIZONTAL=0, VERTICAL=1)
enum AlignmentOrientation { HORIZONTAL, VERTICAL }

extension AlignmentOrientationE on HorizontalAlignment {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Parses [pAlignment] to [AlignmentOrientation]
  static AlignmentOrientation fromString(String pAlignment) {
    return AlignmentOrientation.values[int.parse(pAlignment)];
  }
}
