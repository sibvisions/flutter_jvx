import 'package:flutter/cupertino.dart';

import '../../../util/i_clonable.dart';

/// The [LayoutPosition] are the constraints actually getting applied to a component.
// Author: Toni Heiss
class LayoutPosition implements ICloneable {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The width of the component.
  double width;

  /// The height of the component.
  double height;

  /// The position of the top left component corner from the top in px.
  double top;

  /// The position of the top left component corner from the left in px.
  double left;

  /// Whether the component has this as its size or as a constraint.
  /// (Fixed size or not, e.g. [BorderLayout] has this always `true`)
  bool isComponentSize;

  /// The time of the initial layout call to determine if the [LayoutPosition] is still relevant for components.
  DateTime? timeOfCall;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes a [LayoutPosition].
  LayoutPosition(
      {required this.width,
      required this.height,
      required this.top,
      required this.left,
      required this.isComponentSize,
      this.timeOfCall});

  /// Clones [LayoutPosition] as a deep copy.
  LayoutPosition.from(LayoutPosition pLayoutPosition)
      : width = pLayoutPosition.width,
        height = pLayoutPosition.height,
        top = pLayoutPosition.top,
        left = pLayoutPosition.left,
        isComponentSize = pLayoutPosition.isComponentSize,
        timeOfCall = pLayoutPosition.timeOfCall != null ? DateTime.parse(pLayoutPosition.timeOfCall.toString()) : null;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Clones [LayoutPosition] as a deep copy.
  @override
  LayoutPosition clone() {
    return LayoutPosition.from(this);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "$top, $left | $width, $height | $isComponentSize, $timeOfCall";
  }
}
