import 'dart:ui';
import 'dart:math';

import '../model/layout/alignments.dart';
import '../model/layout/gaps.dart';
import '../model/layout/layout_position.dart';
import '../model/layout/margins.dart';
import '../../util/extensions/string_extensions.dart';

import '../model/layout/layout_data.dart';
import 'i_layout.dart';

class FlowLayout extends ILayout {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The original layout string
  final String layoutString;

  /// The split layout string.
  final List<String> splitLayoutString;

  /// Margins of the BorderLayout
  late final Margins margins;

  /// Gaps between the components
  late final Gaps gaps;

  /// Horizontal alignment of layout
  late final HorizontalAlignment outerHa;

  /// Vertical alignment of layout
  late final VerticalAlignment outerVa;

  /// Alignment of the components
  late final int innerAlignment;

  /// Wether the layout should be wrapped if there is not enough space for all components
  late final bool autoWrap;

  late final bool isRowOrientationHorizontal;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlowLayout({required this.layoutString}) : splitLayoutString = layoutString.split(",") {
    margins = Margins.fromList(marginList: splitLayoutString.sublist(1, 5));
    gaps = Gaps.createFromList(gapsList: splitLayoutString.sublist(5, 7));
    isRowOrientationHorizontal =
        AlignmentOrientationE.fromString(splitLayoutString[7]) == AlignmentOrientation.HORIZONTAL;
    outerHa = HorizontalAlignmentE.fromString(splitLayoutString[8]);
    outerVa = VerticalAlignmentE.fromString(splitLayoutString[9]);
    innerAlignment = int.parse(splitLayoutString[10]);
    autoWrap = splitLayoutString[11].parseBoolDefault(false);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  ILayout clone() {
    return FlowLayout(layoutString: layoutString);
  }

  @override
  void calculateLayout(LayoutData pParent, List<LayoutData> pChildren) {

    /** Sorts the Childcomponent based on indexOf property */
    pChildren.sort((a, b) => a.indexOf! - b.indexOf!);

    double dimWidth = 0;
    double dimHeight = 0;

    if(pParent.hasPosition) {
      dimWidth = pParent.layoutPosition!.width;
      dimHeight = pParent.layoutPosition!.height;
    } else {
      double maxHeight = 0;
      double maxWidth = 0;
      for(LayoutData child in pChildren) {
        if (child.calculatedSize!.height > maxHeight) {
          maxHeight = child.calculatedSize!.height;
        }
        if (child.calculatedSize!.width > maxWidth) {
          maxWidth = child.calculatedSize!.width;
        }
      }
      dimWidth = maxWidth;
      dimHeight = maxHeight;
    }

    dimWidth -= pParent.insets!.left + pParent.insets!.right + margins.marginLeft + margins.marginRight;
    dimHeight -= pParent.insets!.top + pParent.insets!.bottom + margins.marginTop + margins.marginBottom;

    Size dimSize = Size(dimWidth, dimHeight);

    final _FlowGrid flowLayoutInfo = calculateGrid(dimSize, pChildren);



    Size prefSize = Size(
        (flowLayoutInfo.gridWidth * flowLayoutInfo.columns + gaps.horizontalGap * (flowLayoutInfo.columns - 1)),
        (flowLayoutInfo.gridHeight * flowLayoutInfo.rows + gaps.verticalGap * (flowLayoutInfo.rows - 1)));

    double iLeft;
    double iWidth;

    if (outerHa == HorizontalAlignment.STRETCH) {
      iLeft = margins.marginLeft;
      iWidth = dimSize.width;
    } else {
      iLeft = (dimSize.width - prefSize.width) * _getAlignmentFactor(outerHa.index) +
          margins.marginLeft +
          pParent.insets!.left;
      iWidth = prefSize.width;
    }

    double iTop;
    double iHeight;

    if (outerVa == VerticalAlignment.STRETCH) {
      iTop = margins.marginTop;
      iHeight = dimSize.height;
    } else {
      iTop = (dimSize.height - prefSize.height) * _getAlignmentFactor(outerVa.index) +
          margins.marginTop +
          pParent.insets!.top;
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
      if (child.needsRelayout) {
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
                isComponentSize: true);
          } else {
            child.layoutPosition = LayoutPosition(
                left: iLeft + x * fW / fPW,
                top: iTop +
                    y +
                    ((flowLayoutInfo.gridHeight - size.height) * _getAlignmentFactor(innerAlignment)) * fH / fPH,
                width: size.width * fW / fPW,
                height: size.height * fH / fPH,
                isComponentSize: true);
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
                isComponentSize: true);
          } else {
            child.layoutPosition = LayoutPosition(
                left: iLeft +
                    x +
                    ((flowLayoutInfo.gridWidth - size.width) * _getAlignmentFactor(innerAlignment)) * fW / fPW,
                top: iTop + y * fH / fPH,
                width: size.width * fW / fPW,
                height: size.height * fH / fPH,
                isComponentSize: true);
          }

          y += size.height + gaps.verticalGap;
        }
      }
    }
    if(!pParent.hasPosition){
      pParent.calculatedSize = Size(fPW, fPH);
    } else {

      if(pParent.isWidthConstrained){
        pParent.widthConstrains[pParent.layoutPosition!.width] = fPH;
      }
      if(pParent.isHeightConstrained){
        pParent.heightConstrains[pParent.layoutPosition!.height] = fPW;
      }
    }
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
        throw Exception("Cant evaluate alignmentfactor for alignment: $pEnumIndex");
    }
  }

  /// Calculates the grid for the FlowLayout
  _FlowGrid calculateGrid(Size pContainerSize, List<LayoutData> pChildren) {
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
      if (component.needsRelayout) {
        Size prefSize = component.bestSize;
        if (isRowOrientationHorizontal) {
          /** If this isn't the first component add the gap between components*/
          if (!bFirst) {
            calcWidth += gaps.horizontalGap;
          }
          calcWidth += prefSize.width;
          /** Check for the tallest component in row orientation */
          height = max(height, prefSize.height);

          /** If autowrapping is true and the width of the row is greater than the width of the layout, add a new row */
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

          /** If autowrapping is true and the height of the column is greater than the height of the layout, add a new column */
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
