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

import '../../util/i_clonable.dart';

/// The [LayoutPosition] are the constraints actually getting applied to a component.
class LayoutPosition implements ICloneable {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Date of creation
  DateTime creationDate;

  /// The width of the component.
  double width;

  /// The height of the component.
  double height;

  /// The position of the top left component corner from the top in px.
  double top;

  /// The position of the top left component corner from the left in px.
  double left;

  /// Whether or not the position is only to recalc the component
  bool isConstraintCalc;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes a [LayoutPosition].
  LayoutPosition({
    required this.width,
    required this.height,
    required this.top,
    required this.left,
    this.isConstraintCalc = false,
    DateTime? creationDate,
  }) : creationDate = creationDate ?? DateTime.now();

  /// Clones [LayoutPosition] as a deep copy.
  factory LayoutPosition.from(LayoutPosition pLayoutPosition) {
    return pLayoutPosition.clone();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Clones [LayoutPosition] as a deep copy.
  @override
  LayoutPosition clone() {
    return LayoutPosition(
      width: width,
      height: height,
      top: top,
      left: left,
      isConstraintCalc: isConstraintCalc,
      creationDate: creationDate,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LayoutPosition &&
        width == other.width &&
        height == other.height &&
        top == other.top &&
        left == other.left &&
        isConstraintCalc == other.isConstraintCalc;
  }

  @override
  int get hashCode => width.hashCode ^ height.hashCode ^ top.hashCode ^ left.hashCode ^ isConstraintCalc.hashCode;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "$top, $left | $width, $height | $creationDate";
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Size toSize() {
    return Size(width, height);
  }
}
