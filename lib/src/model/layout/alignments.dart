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

import 'package:flutter/widgets.dart';

/// Possible Vertical Alignments (TOP=0, CENTER=1, BOTTOM=2, STRETCH=3)
enum VerticalAlignment { TOP, CENTER, BOTTOM, STRETCH }

extension VerticalAlignmentE on VerticalAlignment {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Gets [alignment] as [VerticalAlignment]
  static VerticalAlignment fromInt(int alignment) {
    return VerticalAlignment.values[alignment];
  }

  /// Parses [alignment] to [VerticalAlignment]
  static VerticalAlignment fromString(String alignment) {
    return VerticalAlignment.values[int.parse(alignment)];
  }

  /// Parses [alignment] to [VerticalAlignment]
  static VerticalAlignment fromDynamic(dynamic alignment) {
    if (alignment is String) {
      return VerticalAlignment.values[int.parse(alignment)];
    }
    else if (alignment is int) {
      return VerticalAlignment.values[alignment];
    }

    return VerticalAlignment.values[int.parse(alignment.toString())];
  }

  static TextAlignVertical toTextAlign(VerticalAlignment alignment) {
    switch (alignment) {
      case VerticalAlignment.TOP:
        return TextAlignVertical.top;
      case VerticalAlignment.CENTER:
        return TextAlignVertical.center;
      case VerticalAlignment.BOTTOM:
        return TextAlignVertical.bottom;
      case VerticalAlignment.STRETCH:
        return TextAlignVertical.center;
    }
  }
}

/// Possible Horizontal Alignments (LEFT=0, CENTER=1, RIGHT=2, STRETCH=3)
enum HorizontalAlignment { LEFT, CENTER, RIGHT, STRETCH }

extension HorizontalAlignmentE on HorizontalAlignment {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Gets [alignment] as [HorizontalAlignment]
  static HorizontalAlignment fromInt(int alignment) {
    return HorizontalAlignment.values[alignment];
  }

  /// Parses [alignment] to [HorizontalAlignment]
  static HorizontalAlignment fromString(String alignment) {
    return HorizontalAlignment.values[int.parse(alignment)];
  }

  /// Parses [alignment] to [HorizontalAlignment]
  static HorizontalAlignment fromDynamic(dynamic alignment) {
    if (alignment is String) {
      return HorizontalAlignment.values[int.parse(alignment)];
    }
    else if (alignment is int) {
      return HorizontalAlignment.values[alignment];
    }

    return HorizontalAlignment.values[int.parse(alignment.toString())];
  }

  static TextAlign toTextAlign(HorizontalAlignment alignment) {
    switch (alignment) {
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

/// Possible Orientation {HORIZONTAL=0, VERTICAL=1)
enum AlignmentOrientation { HORIZONTAL, VERTICAL }

extension AlignmentOrientationE on HorizontalAlignment {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Parses [alignment] to [AlignmentOrientation]
  static AlignmentOrientation fromString(String alignment) {
    return AlignmentOrientation.values[int.parse(alignment)];
  }
}

/// Two-dimensional array translating JVx alignment constants to Flutter alignment constants.
/// The first index is the horizontal alignment, the second index is the vertical alignment.
const FLUTTER_ALIGNMENT = [
  [Alignment.topLeft, Alignment.centerLeft, Alignment.bottomLeft, Alignment.centerLeft],
  [Alignment.topCenter, Alignment.center, Alignment.bottomCenter, Alignment.center],
  [Alignment.topRight, Alignment.centerRight, Alignment.bottomRight, Alignment.centerRight],
  [Alignment.topCenter, Alignment.center, Alignment.bottomCenter, Alignment.center],
];
