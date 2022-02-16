import 'dart:collection';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/layout/grid_layout/cell_constraints.dart';
import 'package:flutter_client/src/model/layout/grid_layout/grid_size.dart';
import 'package:flutter_client/src/model/layout/layout_position.dart';
import 'package:flutter_client/src/model/layout/margins.dart';

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
  late  final Gaps gaps;
  /// Size of the grid
  late final GridSize gridSize;

  GridLayout({required String layoutString}) {
    List<String> splitLayout = layoutString.split(",");
    
    margins = Margins.fromList(marginList: splitLayout.sublist(1,5));
    gaps = Gaps.createFromList(gapsList: splitLayout.sublist(5, 7));
    gridSize = GridSize.fromList(list: splitLayout.sublist(7,9));
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

    // Total width of the layout
    int totalWidth = 0;
    // Total height of the layout
    int totalHeight = 0;

    HashMap<String, CellConstraint> cellConstraints = HashMap();

    for(LayoutData data in pChildren) {
      // Generate constraints
      List<String> splitConstraint = data.constraints!.split(RegExp("[;,]"));
      CellConstraint componentConstraint = CellConstraint(
          margins: Margins.fromList(marginList: splitConstraint.sublist(4)),
          gridHeight: int.parse(splitConstraint[3]),
          gridWidth: int.parse(splitConstraint[2]),
          gridY: int.parse(splitConstraint[1]),
          gridX: int.parse(splitConstraint[0])
      );

      cellConstraints[data.id] = componentConstraint;

      Size prefSize = data.bestSize;

      //  Calculate how wide one single grid would be for the component based on the preferred width and how many grids the component is wide
      int widthOneField = (prefSize.width / componentConstraint.gridWidth).ceil();
      // Calculate how tall one single grid would be for the component based on the preferred height and how many grids the component is tall
      int heightOneField = (prefSize.width / componentConstraint.gridWidth).ceil();
      if(widthOneField > widest){
        widest = widthOneField;
      }
      if(heightOneField > tallest){
        tallest = heightOneField;
      }
    }

    if(pParent.hasPosition){
      totalHeight = pParent.layoutPosition!.height.ceil();
      totalWidth = pParent.layoutPosition!.width.ceil();
    } else {
      totalWidth = (widest * gridSize.columns - margins.marginLeft - margins.marginRight).ceil();
      totalHeight = (tallest * gridSize.rows - margins.marginTop - margins.marginBottom).ceil();
    }

    Size fieldSize = Size(totalWidth/gridSize.columns, totalHeight/gridSize.rows);

    for(LayoutData data in pChildren){
      CellConstraint constraint = cellConstraints[data.id]!;

      double calculatedWidth = constraint.gridWidth * (fieldSize.width - (gaps.horizontalGap / constraint.gridWidth - gaps.horizontalGap / gridSize.columns));
      double calculatedHeight = constraint.gridHeight * (fieldSize.height - (gaps.verticalGap / constraint.gridHeight - gaps.verticalGap / gridSize.rows));

      double calculatedTop = constraint.gridY * (fieldSize.height - (gaps.verticalGap - gaps.verticalGap / gridSize.rows) + gaps.verticalGap);
      double calculatedLeft = constraint.gridX * (fieldSize.width - (gaps.horizontalGap - gaps.horizontalGap / gridSize.columns) + gaps.horizontalGap);

      data.layoutPosition = LayoutPosition(
          width: calculatedWidth,
          height: calculatedHeight,
          top: calculatedTop,
          left: calculatedLeft,
          isComponentSize: true
      );
    }
    pParent.calculatedSize = Size(totalWidth.toDouble(), totalHeight.toDouble());
  }
}
