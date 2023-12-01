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

import 'package:flutter/material.dart';

import '../../../layout/i_layout.dart';

/// Constraints of a cell in a gridLayout
class CellConstraint {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The position on the x-axis
  int gridX;

  /// The position on the y-axis
  int gridY;

  /// The width of the component in grids (how many grids it spans)
  int gridWidth;

  /// The height of the component in grids (how many grids it spans)
  int gridHeight;

  /// The margins of the component
  EdgeInsets margins;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Creates a [CellConstraint] instance
  CellConstraint(
      {required this.margins,
      required this.gridHeight,
      required this.gridWidth,
      required this.gridX,
      required this.gridY});

  CellConstraint.fromList(List<String> splitConstraint, double scaling)
      : margins = ILayout.marginsFromList(marginList: splitConstraint.sublist(4), scaling: scaling),
        gridHeight = int.parse(splitConstraint[3]),
        gridWidth = int.parse(splitConstraint[2]),
        gridY = int.parse(splitConstraint[1]),
        gridX = int.parse(splitConstraint[0]);
}
