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

  GridLayout({required this.layoutString, required this.scaling}) {
    List<String> layoutList = layoutString.split(",");

    margins = ILayout.marginsFromList(marginList: layoutList.sublist(1, 5), scaling: scaling);
    gaps = Gaps.createFromList(gapsList: layoutList.sublist(5, 7), scaling: scaling);
    gridSize = GridSize.fromList(list: layoutList.sublist(7, 9));
  }

  @override
  ILayout clone() {
    return GridLayout(layoutString: layoutString, scaling: scaling);
  }

  @override
  void calculateLayout(LayoutData pParent, List<LayoutData> pChildren) {
    // The widest single grid of all components
    num maxWidth = 0;
    // The tallest single grid of all components
    num maxHeight = 0;

    HashMap<String, CellConstraint> cellConstraints = HashMap();

    int targetColumns = gridSize.columns;
    int targetRows = gridSize.rows;

    for (LayoutData data in pChildren) {
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
        pParent.insets.horizontal +
        margins.horizontal +
        (targetColumns - 1) * gaps.horizontalGap;

    double calcHeight =
        maxHeight * targetRows + pParent.insets.vertical + margins.vertical + (targetRows - 1) * gaps.verticalGap;

    double sizeWidth = pParent.layoutPosition?.width ?? calcWidth;
    double sizeHeight = pParent.layoutPosition?.height ?? calcHeight;

    List<num> xPositions = [];
    List<num> yPositions = [];
    int columnWidth = 0;
    int rowHeight = 0;

    if (targetColumns > 0 && targetRows > 0) {
      final int totalGapsWidth = (targetColumns - 1) * gaps.horizontalGap;
      final int totalGapsHeight = (targetRows - 1) * gaps.verticalGap;

      final num totalWidth = sizeWidth - margins.right - totalGapsWidth;
      final num totalHeight = sizeHeight - margins.bottom - totalGapsHeight;

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

      yPositions.add(margins.left);
      int corrY = 0;
      for (int i = 0; i < targetRows; i++) {
        yPositions.add(yPositions[i] + rowHeight + gaps.verticalGap);
        if (heightCalcError > 0 && (corrY * targetRows / heightCalcError + yMiddle).floor() == i) {
          yPositions.last = yPositions.last + 1;
          corrY++;
        }
      }
    }

    for (LayoutData data in pChildren) {
      CellConstraint constraint = cellConstraints[data.id]!;

      final num left =
          getPosition(xPositions, constraint.gridX, columnWidth, gaps.horizontalGap) + constraint.margins.left;
      final num top = getPosition(yPositions, constraint.gridY, rowHeight, gaps.verticalGap) + constraint.margins.top;
      final num width =
          getPosition(xPositions, constraint.gridX + constraint.gridWidth, columnWidth, gaps.horizontalGap) -
              left -
              gaps.horizontalGap -
              constraint.margins.right;
      final num height =
          getPosition(yPositions, constraint.gridY + constraint.gridHeight, rowHeight, gaps.verticalGap) -
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

    pParent.calculatedSize = Size(calcWidth, calcHeight);
  }

  num getPosition(List<num> pPositions, int pIndex, num pSize, num pGap) {
    if (pIndex < 0) {
      return pPositions[0] + pIndex * (pSize + pGap);
    } else if (pIndex >= pPositions.length) {
      return pPositions[pPositions.length - 1] + (pIndex - pPositions.length + 1) * (pSize + pGap);
    } else {
      return pPositions[pIndex];
    }
  }
}
