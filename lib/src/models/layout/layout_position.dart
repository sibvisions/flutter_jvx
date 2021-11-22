import 'package:flutter_jvx/src/util/i_clonable.dart';

/// The [LayoutPosition] are the constraints actually getting applied to a component.
// Author: Toni Heiss
class LayoutPosition implements ICloneable{
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The width of the component.
  double width;

  /// The height of the component.
  double height;

  /// The position of the top left component corner from the top in px.
  double? top;

  /// The position of the top left component corner from the left in px.
  double? left;

  /// The position of the top left component corner from the bottom in px.
  double? bottom;

  /// The position of the top left component corner from the right in px.
  double? right;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes a [LayoutPosition].
  LayoutPosition({required this.width, required this.height, this.top, this.left, this.right, this.bottom});

  /// Clones [LayoutPosition] as a deep copy.
  LayoutPosition.from(LayoutPosition pLayoutPosition) :
    width = pLayoutPosition.width,
    height = pLayoutPosition.height,
    top = pLayoutPosition.top,
    left = pLayoutPosition.left,
    bottom = pLayoutPosition.bottom,
    right = pLayoutPosition.right;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Clones [LayoutPosition] as a deep copy.
  @override
  LayoutPosition clone() {
    return LayoutPosition.from(this);
  }
}
