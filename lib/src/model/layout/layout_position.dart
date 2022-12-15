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

import '../../util/i_clonable.dart';

/// The [LayoutPosition] are the constraints actually getting applied to a component.
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

  /// Whether or not the position is only to recalc the component
  bool isConstraintCalc;

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
      this.isConstraintCalc = false});

  /// Clones [LayoutPosition] as a deep copy.
  LayoutPosition.from(LayoutPosition pLayoutPosition)
      : width = pLayoutPosition.width,
        height = pLayoutPosition.height,
        top = pLayoutPosition.top,
        left = pLayoutPosition.left,
        isComponentSize = pLayoutPosition.isComponentSize,
        isConstraintCalc = pLayoutPosition.isConstraintCalc;

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
    return "$top, $left | $width, $height | $isComponentSize";
  }
}
