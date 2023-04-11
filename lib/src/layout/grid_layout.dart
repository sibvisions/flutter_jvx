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
    List<String> splitLayout = layoutString.split(",");

    margins = ILayout.marginsFromList(marginList: splitLayout.sublist(1, 5), scaling: scaling);
    gaps = Gaps.createFromList(gapsList: splitLayout.sublist(5, 7), scaling: scaling);
    gridSize = GridSize.fromList(list: splitLayout.sublist(7, 9));
  }

  @override
  ILayout clone() {
    return GridLayout(layoutString: layoutString, scaling: scaling);
  }

  @override
  void calculateLayout(LayoutData pParent, List<LayoutData> pChildren) {
    // The widest singe grid of all components
    int widest = 0;
    // The tallest single grid of all components
    int tallest = 0;

    HashMap<String, CellConstraint> cellConstraints = HashMap();

    for (LayoutData data in pChildren) {
      // Generate constraints
      List<String> splitConstraint = data.constraints!.split(RegExp("[;,]"));
      CellConstraint componentConstraint = CellConstraint(
          margins: ILayout.marginsFromList(marginList: splitConstraint.sublist(4), scaling: scaling),
          gridHeight: (int.parse(splitConstraint[3]) * scaling).ceil(),
          gridWidth: (int.parse(splitConstraint[2]) * scaling).ceil(),
          gridY: (int.parse(splitConstraint[1]) * scaling).ceil(),
          gridX: (int.parse(splitConstraint[0]) * scaling).ceil());

      cellConstraints[data.id] = componentConstraint;

      Size prefSize = data.bestSize;

      //  Calculate how wide one single grid would be for the component based on the preferred width and how many grids the component is wide
      int widthOneField = (prefSize.width / componentConstraint.gridWidth).ceil();
      // Calculate how tall one single grid would be for the component based on the preferred height and how many grids the component is tall
      int heightOneField = (prefSize.height / componentConstraint.gridHeight).ceil();
      if (widthOneField > widest) {
        widest = widthOneField;
      }
      if (heightOneField > tallest) {
        tallest = heightOneField;
      }
    }

    double calcWidth = widest * gridSize.columns +
        (gridSize.columns - 1) * gaps.horizontalGap +
        pParent.insets.horizontal +
        margins.horizontal;
    double calcHeight =
        tallest * gridSize.rows + (gridSize.rows - 1) * gaps.verticalGap + pParent.insets.vertical + margins.horizontal;

    Size preferredSize = Size(calcWidth, calcHeight);

    double fieldWidth = pParent.layoutPosition?.width ?? calcWidth;
    double fieldHeight = pParent.layoutPosition?.height ?? calcHeight;

    fieldWidth -= pParent.insets.horizontal + margins.horizontal;
    fieldHeight -= pParent.insets.vertical + margins.vertical;
    Size fieldSize = Size(fieldWidth / gridSize.columns, fieldHeight / gridSize.rows);

    for (LayoutData data in pChildren) {
      CellConstraint constraint = cellConstraints[data.id]!;

      double calculatedWidth = constraint.gridWidth *
          (fieldSize.width - (gaps.horizontalGap / constraint.gridWidth - gaps.horizontalGap / gridSize.columns));
      double calculatedHeight = constraint.gridHeight *
          (fieldSize.height - (gaps.verticalGap / constraint.gridHeight - gaps.verticalGap / gridSize.rows));

      double calculatedTop = constraint.gridY *
          (fieldSize.height - (gaps.verticalGap - gaps.verticalGap / gridSize.rows) + gaps.verticalGap);
      double calculatedLeft = constraint.gridX *
          (fieldSize.width - (gaps.horizontalGap - gaps.horizontalGap / gridSize.columns) + gaps.horizontalGap);

      data.layoutPosition = LayoutPosition(
          width: calculatedWidth,
          height: calculatedHeight,
          top: calculatedTop + margins.top,
          left: calculatedLeft + margins.left,
          isComponentSize: true);
    }
    pParent.calculatedSize = preferredSize;
  }
}
