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
import '../model/layout/grid_layout/cell_constraints.dart';
import '../model/layout/grid_layout/grid_size.dart';
import '../model/layout/layout_data.dart';
import '../model/layout/layout_position.dart';
import 'i_layout.dart';

class GridLayout extends ILayout {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The original layout string
  final String layoutString;

  /// The modifier with which to scale the layout.
  final double scaling;

  /// Gaps between grid cells
  late final Gaps gaps;

  /// Size of the grid
  late final GridSize gridSize;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  GridLayout({
    required this.layoutString,
    required this.scaling
  }) {
    List<String> layoutDef = layoutString.split(",");

    margins = ILayout.marginsFromList(marginList: layoutDef.sublist(1, 5), scaling: scaling);
    gaps = Gaps.createFromList(gapsList: layoutDef.sublist(5, 7), scaling: scaling);
    gridSize = GridSize.fromList(list: layoutDef.sublist(7, 9));
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  ILayout clone() {
    return GridLayout(layoutString: layoutString, scaling: scaling);
  }

  @override
  void calculateLayout(LayoutData parent, List<LayoutData> children) {
    // The widest single grid of all components
    num maxWidth = 0;
    // The tallest single grid of all components
    num maxHeight = 0;

    HashMap<String, CellConstraint> cellConstraints = HashMap();

    int targetColumns = gridSize.columns;
    int targetRows = gridSize.rows;

    for (LayoutData data in children) {
      // Generate constraints
      CellConstraint constraints = CellConstraint.fromList(data.constraints!.split(RegExp("[;,]")), scaling);
      cellConstraints[data.id] = constraints;

      Size prefSize = data.bestSize;

      int width =
          ((prefSize.width + constraints.gridWidth - 1) / constraints.gridWidth + constraints.margins.horizontal)
              .floor();
      if (width > maxWidth) {
        maxWidth = width;
      }

      var height =
          ((prefSize.height + constraints.gridHeight - 1) / constraints.gridHeight + constraints.margins.vertical)
              .floor();
      if (height > maxHeight) {
        maxHeight = height;
      }

      if (gridSize.columns <= 0 && constraints.gridX + constraints.gridWidth > targetColumns) {
        targetColumns = constraints.gridX + constraints.gridWidth;
      }
      if (gridSize.rows <= 0 && constraints.gridY + constraints.gridHeight > targetRows) {
        targetRows = constraints.gridY + constraints.gridHeight;
      }
    }

    double calcWidth = maxWidth * targetColumns +
        parent.insets.horizontal +
        margins.horizontal +
        (targetColumns - 1) * gaps.horizontalGap;

    double calcHeight =
        maxHeight * targetRows + parent.insets.vertical + margins.vertical + (targetRows - 1) * gaps.verticalGap;

    double sizeWidth = parent.layoutPosition?.width ?? calcWidth;
    double sizeHeight = parent.layoutPosition?.height ?? calcHeight;

    List<num> xPositions = [];
    List<num> yPositions = [];
    int columnWidth = 0;
    int rowHeight = 0;

    if (targetColumns > 0 && targetRows > 0) {
      final int totalGapsWidth = (targetColumns - 1) * gaps.horizontalGap;
      final int totalGapsHeight = (targetRows - 1) * gaps.verticalGap;

      final num totalWidth = sizeWidth - margins.horizontal - totalGapsWidth;
      final num totalHeight = sizeHeight - margins.vertical - totalGapsHeight;

      columnWidth = (totalWidth / targetColumns).floor();
      rowHeight = (totalHeight / targetRows).floor();

      final num widthCalcError = totalWidth - columnWidth * targetColumns;
      final num heightCalcError = totalHeight - rowHeight * targetRows;
      int xMiddle = 0;
      if (widthCalcError > 0) {
        xMiddle = ((targetColumns / widthCalcError + 1) / 2).floor();
      }
      int yMiddle = 0;
      if (heightCalcError > 0) {
        yMiddle = ((targetRows / heightCalcError + 1) / 2).floor();
      }

      xPositions.add(margins.left);
      int corrX = 0;
      for (int i = 0; i < targetColumns; i++) {
        xPositions.add(xPositions[i] + columnWidth + gaps.horizontalGap);
        if (widthCalcError > 0 && (corrX * targetColumns / widthCalcError + xMiddle).floor() == i) {
          xPositions.last = xPositions.last + 1;
          corrX++;
        }
      }

      yPositions.add(margins.top);
      int corrY = 0;
      for (int i = 0; i < targetRows; i++) {
        yPositions.add(yPositions[i] + rowHeight + gaps.verticalGap);
        if (heightCalcError > 0 && (corrY * targetRows / heightCalcError + yMiddle).floor() == i) {
          yPositions.last = yPositions.last + 1;
          corrY++;
        }
      }
    }

    for (LayoutData data in children) {
      CellConstraint constraint = cellConstraints[data.id]!;

      final num left = _getPosition(xPositions, constraint.gridX, columnWidth, gaps.horizontalGap) + constraint.margins.left;
      final num top = _getPosition(yPositions, constraint.gridY, rowHeight, gaps.verticalGap) + constraint.margins.top;
      final num width =
          _getPosition(xPositions, constraint.gridX + constraint.gridWidth, columnWidth, gaps.horizontalGap) -
              left -
              gaps.horizontalGap -
              constraint.margins.right;
      final num height =
          _getPosition(yPositions, constraint.gridY + constraint.gridHeight, rowHeight, gaps.verticalGap) -
              top -
              gaps.verticalGap -
              constraint.margins.bottom;

      data.layoutPosition = LayoutPosition(
        width: width.toDouble(),
        height: height.toDouble(),
        top: top.toDouble(),
        left: left.toDouble(),
      );
    }

    parent.calculatedSize = Size(calcWidth, calcHeight);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  num _getPosition(List<num> positions, int index, num size, num gap) {
    if (index < 0) {
      return positions[0] + index * (size + gap);
    } else if (index >= positions.length) {
      return positions[positions.length - 1] + (index - positions.length + 1) * (size + gap);
    } else {
      return positions[index];
    }
  }
}
