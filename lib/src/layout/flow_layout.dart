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

import 'dart:math';
import 'dart:ui';

import '../model/layout/alignments.dart';
import '../model/layout/gaps.dart';
import '../model/layout/layout_data.dart';
import '../model/layout/layout_position.dart';
import '../util/parse_util.dart';
import 'i_layout.dart';

class FlowLayout extends ILayout {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The original layout string
  final String layoutString;

  /// The split layout string.
  final List<String> splitLayoutString;

  /// Gaps between the components
  late final Gaps gaps;

  /// Horizontal alignment of layout
  late final HorizontalAlignment outerHa;

  /// Vertical alignment of layout
  late final VerticalAlignment outerVa;

  /// Alignment of the components
  late final int innerAlignment;

  /// Whether the layout should be wrapped if there is not enough space for all components
  late final bool autoWrap;

  late final bool isRowOrientationHorizontal;

  /// The modifier with which to scale the layout.
  final double scaling;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlowLayout({required this.layoutString, required this.scaling}) : splitLayoutString = layoutString.split(",") {
    margins = ILayout.marginsFromList(marginList: splitLayoutString.sublist(1, 5), scaling: scaling);
    gaps = Gaps.createFromList(gapsList: splitLayoutString.sublist(5, 7), scaling: scaling);
    isRowOrientationHorizontal =
        AlignmentOrientationE.fromString(splitLayoutString[7]) == AlignmentOrientation.HORIZONTAL;
    outerHa = HorizontalAlignmentE.fromString(splitLayoutString[8]);
    outerVa = VerticalAlignmentE.fromString(splitLayoutString[9]);
    innerAlignment = int.parse(splitLayoutString[10]);
    autoWrap = ParseUtil.parseBoolOrFalse(splitLayoutString[11]);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  ILayout clone() {
    return FlowLayout(layoutString: layoutString, scaling: scaling);
  }

  @override
  void calculateLayout(LayoutData pParent, List<LayoutData> pChildren) {
    /** Sorts the Child component based on indexOf property */
    pChildren.sort((a, b) => a.indexOf! - b.indexOf!);

    double dimWidth = pParent.layoutPosition?.width ?? 0;
    double dimHeight = pParent.layoutPosition?.height ?? 0;

    dimWidth -= (pParent.insets.horizontal + margins.horizontal);
    dimHeight -= (pParent.insets.vertical + margins.vertical);

    dimHeight = max(0, dimHeight);
    dimWidth = max(0, dimWidth);

    Size dimSize = Size(dimWidth, dimHeight);

    final _FlowGrid flowLayoutInfo = _calculateGrid(dimSize, pChildren);

    Size prefSize = Size(
        (flowLayoutInfo.gridWidth * flowLayoutInfo.columns + gaps.horizontalGap * (flowLayoutInfo.columns - 1)),
        (flowLayoutInfo.gridHeight * flowLayoutInfo.rows + gaps.verticalGap * (flowLayoutInfo.rows - 1)));

    double iLeft;
    double iWidth;

    if (outerHa == HorizontalAlignment.STRETCH) {
      iLeft = margins.left;
      iWidth = dimSize.width;
    } else {
      iLeft = ((dimSize.width - prefSize.width) * _getAlignmentFactor(outerHa.index)) + margins.left;
      iWidth = prefSize.width;
    }

    double iTop;
    double iHeight;

    if (outerVa == VerticalAlignment.STRETCH) {
      iTop = margins.top;
      iHeight = dimSize.height;
    } else {
      iTop = ((dimSize.height - prefSize.height) * _getAlignmentFactor(outerVa.index)) + margins.top;
      iHeight = prefSize.height;
    }

    /** The FlowLayout width */
    double fW = max(1, iWidth);
    /** The FlowLayout preferred width */
    double fPW = max(1, prefSize.width);
    /** The FlowLayout height*/
    double fH = max(1, iHeight);
    /** The FlowLayout preferred height */
    double fPH = max(1, prefSize.height);
    /** x stores the columns */
    double x = 0;
    /** y stores the rows */
    double y = 0;

    bool bFirst = true;

    for (LayoutData child in pChildren) {
      Size size = child.bestSize;

      if (isRowOrientationHorizontal) {
        if (!bFirst && autoWrap && dimSize.width > 0 && x + size.width > dimSize.width) {
          x = 0;
          y += (flowLayoutInfo.gridHeight + gaps.verticalGap) * fH / fPH;
        } else if (bFirst) {
          bFirst = false;
        }

        if (VerticalAlignment.values[innerAlignment] == VerticalAlignment.STRETCH) {
          child.layoutPosition = LayoutPosition(
            left: iLeft + x * fW / fPW,
            top: iTop + y,
            width: size.width * fW / fPW,
            height: flowLayoutInfo.gridHeight * fH / fPH,
          );
        } else {
          child.layoutPosition = LayoutPosition(
            left: iLeft + x * fW / fPW,
            top:
                iTop + y + ((flowLayoutInfo.gridHeight - size.height) * _getAlignmentFactor(innerAlignment)) * fH / fPH,
            width: size.width * fW / fPW,
            height: size.height * fH / fPH,
          );
        }

        x += size.width + gaps.horizontalGap;
      } else {
        if (!bFirst && autoWrap && dimSize.height > 0 && y + size.height > dimSize.height) {
          y = 0;
          x += (flowLayoutInfo.gridWidth + gaps.horizontalGap) * fW / fPW;
        } else if (bFirst) {
          bFirst = false;
        }

        if (HorizontalAlignment.values[innerAlignment] == HorizontalAlignment.STRETCH) {
          child.layoutPosition = LayoutPosition(
            left: iLeft + x,
            top: iTop + y * fH / fPH,
            width: flowLayoutInfo.gridWidth * fW / fPW,
            height: size.height * fH / fPH,
          );
        } else {
          child.layoutPosition = LayoutPosition(
            left:
                iLeft + x + ((flowLayoutInfo.gridWidth - size.width) * _getAlignmentFactor(innerAlignment)) * fW / fPW,
            top: iTop + y * fH / fPH,
            width: size.width * fW / fPW,
            height: size.height * fH / fPH,
          );
        }

        y += size.height + gaps.verticalGap;
      }
    }

    pParent.calculatedSize = prefSize +
        Offset(
          margins.horizontal + pParent.insets.horizontal,
          margins.vertical + pParent.insets.vertical,
        );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static double _getAlignmentFactor(int pEnumIndex) {
    switch (pEnumIndex) {
      case 0: // HorizontalAlignment.LEFT or VerticalAlignment.TOP
      case 3: // HorizontalAlignment.STRETCH or VerticalAlignment.STRETCH
        return 0;
      case 1: // HorizontalAlignment.CENTER or VerticalAlignment.CENTER
        return 0.5;
      case 2: // HorizontalAlignment.RIGHT or VerticalAlignment.BOTTOM
        return 1;
      default:
        throw Exception("Cant evaluate alignment factor for alignment: $pEnumIndex");
    }
  }

  /// Calculates the grid for the FlowLayout
  _FlowGrid _calculateGrid(Size pContainerSize, List<LayoutData> pChildren) {
    /// Calculated height of the latest column of the FlowLayout
    double calcHeight = 0;

    /// Calculated width of the latest row of the FlowLayout
    double calcWidth = 0;

    /// The width of the FlowLayout
    double width = 0;

    /// The height of the FlowLayout
    double height = 0;

    /// The amount of rows in the FlowLayout
    int anzRows = 1;

    /// The amount of columns in the FlowLayout
    int anzCols = 1;

    /// If the current component is the first
    bool bFirst = true;

    for (LayoutData component in pChildren) {
      Size prefSize = component.bestSize;
      if (isRowOrientationHorizontal) {
        /** If this isn't the first component add the gap between components*/
        if (!bFirst) {
          calcWidth += gaps.horizontalGap;
        }
        calcWidth += prefSize.width;
        /** Check for the tallest component in row orientation */
        height = max(height, prefSize.height);

        /** If auto wrapping is true and the width of the row is greater than the width of the layout, add a new row */
        if (!bFirst && autoWrap && pContainerSize.width > 0 && calcWidth > pContainerSize.width) {
          calcWidth = prefSize.width;
          anzRows++;
        } else if (bFirst) {
          bFirst = false;
        }
        /** Check if the current row is wider than the current width of the FlowLayout */
        width = max(width, calcWidth);
      } else {
        /** If this isn't the first component add the gap between components*/
        if (!bFirst) {
          calcHeight += gaps.verticalGap;
        }
        calcHeight += prefSize.height;
        /** Check for the widest component in row orientation */
        width = max(width, prefSize.width);

        /** If auto wrapping is true and the height of the column is greater than the height of the layout, add a new column */
        if (!bFirst && autoWrap && pContainerSize.height > 0 && calcHeight > pContainerSize.height) {
          calcHeight = prefSize.height;
          anzCols++;
        } else if (bFirst) {
          bFirst = false;
        }
        /** Check if the current column is taller than the current height of the FlowLayout */
        height = max(height, calcHeight);
      }
    }

    return _FlowGrid(columns: anzCols, rows: anzRows, gridWidth: width, gridHeight: height);
  }
} // FlowLayout

class _FlowGrid {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The amount of columns in the FlowLayout
  int columns;

  /// The amount of rows in the FlowLayout
  int rows;

  /// The width of the FlowLayout
  double gridWidth;

  /// The height of the FlowLayout
  double gridHeight;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  _FlowGrid({required this.columns, required this.rows, required this.gridWidth, required this.gridHeight});
} // FlowGrid
