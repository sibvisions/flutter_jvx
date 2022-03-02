import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../model/layout/grid_layout/cell_constraints.dart';
import '../model/layout/grid_layout/grid_size.dart';
import '../model/layout/layout_position.dart';
import '../model/layout/margins.dart';

import '../model/layout/layout_data.dart';
import '../model/layout/gaps.dart';
import 'i_layout.dart';

class GridLayout extends ILayout {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Margins of the Grid Layout
  late final Margins margins;

  /// Gaps between grid cells
  late final Gaps gaps;

  /// Size of the grid
  late final GridSize gridSize;

  GridLayout({required String layoutString}) {
    List<String> splitLayout = layoutString.split(",");

    margins = Margins.fromList(marginList: splitLayout.sublist(1, 5));
    gaps = Gaps.createFromList(gapsList: splitLayout.sublist(5, 7));
    gridSize = GridSize.fromList(list: splitLayout.sublist(7, 9));
  }

  @override
  ILayout clone() {
    return this;
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
          margins: Margins.fromList(marginList: splitConstraint.sublist(4)),
          gridHeight: int.parse(splitConstraint[3]),
          gridWidth: int.parse(splitConstraint[2]),
          gridY: int.parse(splitConstraint[1]),
          gridX: int.parse(splitConstraint[0]));

      cellConstraints[data.id] = componentConstraint;

      Size prefSize = data.bestSize;

      //  Calculate how wide one single grid would be for the component based on the preferred width and how many grids the component is wide
      int widthOneField = (prefSize.width / componentConstraint.gridWidth).ceil();
      // Calculate how tall one single grid would be for the component based on the preferred height and how many grids the component is tall
      int heightOneField = (prefSize.width / componentConstraint.gridWidth).ceil();
      if (widthOneField > widest) {
        widest = widthOneField;
      }
      if (heightOneField > tallest) {
        tallest = heightOneField;
      }
    }

    double calcWidth = widest * gridSize.columns +
        (gridSize.columns - 1) * gaps.verticalGap +
        pParent.insets.left +
        pParent.insets.right +
        margins.marginLeft +
        margins.marginRight;
    double calcHeight = tallest * gridSize.rows +
        (gridSize.rows - 1) * gaps.horizontalGap +
        pParent.insets.top +
        pParent.insets.bottom +
        margins.marginTop +
        margins.marginBottom;

    Size preferredSize = Size(calcWidth, calcHeight);

    double fieldWidth;
    double fieldHeight;

    if (pParent.layoutPosition!.isComponentSize) {
      fieldWidth = pParent.layoutPosition!.width;
      fieldHeight = pParent.layoutPosition!.height;
    } else {
      fieldWidth = max(calcWidth, pParent.layoutPosition!.width);
      fieldHeight = max(calcHeight, pParent.layoutPosition!.height);
    }

    fieldWidth -= pParent.insets.left + pParent.insets.right + margins.marginLeft + margins.marginRight;
    fieldHeight -= pParent.insets.top + pParent.insets.bottom + margins.marginTop + margins.marginBottom;
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
          top: calculatedTop,
          left: calculatedLeft,
          isComponentSize: true);
    }
    pParent.calculatedSize = preferredSize;
  }
}
