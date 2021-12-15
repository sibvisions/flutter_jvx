import 'dart:collection';

import 'package:flutter_client/src/model/layout/alignments.dart';
import 'package:flutter_client/src/model/layout/form_layout/form_layout_anchor.dart';
import 'package:flutter_client/src/model/layout/gaps.dart';
import 'package:flutter_client/src/model/layout/margins.dart';
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

  /// The original layout data string
  final String layoutData;

  /// Margins of the BorderLayout
  late final Margins margins;

  /// Gaps between the components
  late final Gaps gaps;

  /// Horizontal alignment of layout
  late final int outerHa;

  /// Vertical alignment of layout
  late final int outerVa;

  /// Alignment of the components
  late final int innerAlignment;

  /// Wether the layout should be wrapped if there is not enough space for all components
  late final bool autoWrap;

  late final bool isRowOrientationHorizontal;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlowLayout({required this.layoutData, required this.layoutString}) : splitLayoutString = layoutString.split(",") {
    margins = Margins.fromList(marginList: splitLayoutString.sublist(1, 5));
    gaps = Gaps.createFromList(gapsList: splitLayoutString.sublist(5, 7));
    isRowOrientationHorizontal =
        AlignmentOrientationE.fromString(splitLayoutString[7]) == AlignmentOrientation.HORIZONTAL;
    outerHa = int.parse(splitLayoutString[8]);
    outerVa = int.parse(splitLayoutString[9]);
    innerAlignment = int.parse(splitLayoutString[10]);
    autoWrap = splitLayoutString[11].parseBoolDefault(false);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  ILayout clone() {
    return FlowLayout(layoutData: layoutData, layoutString: layoutString);
  }

  @override
  HashMap<String, LayoutData> calculateLayout(LayoutData pParent, List<LayoutData> pChildren) {
    /** Map which contains component ids as key and positioning and sizing properties as value */
    HashMap<String, LayoutData> sizeMap = HashMap();

    // TODO flow index
    /** Sorts the Childcomponent based on indexOf property */
    //const childrenSorted = new Map([...children.entries()].sort((a, b) => {return (a[1].indexOf as number) - (b[1].indexOf as number)}));

    //       const toolBarsFiltered:[string, BaseComponent][]|undefined = parent ?
    //           id.includes("-tbMain") ?
    //               [...context.contentStore.getChildren(id, className)]
    //           :
    //               [...context.contentStore.getChildren(parent, className)].filter(child => child[1].className === COMPONENT_CLASSNAMES.TOOLBAR )
    //       : undefined;

    //       const toolbarGap = isToolBar ? parseInt(window.getComputedStyle(document.documentElement).getPropertyValue('--toolbar-button-gap')) : 0;

    //       /**
    //        * Checks whether the bar is either the first or the last toolbar depending on "first" parameter
    //        * @param id - the id of the toolbar
    //        * @param first - whether to check if the toolbar is the first or the last
    //        * @returns
    //        */
    //       const checkFirstOrLastToolBar = (id:string, first:boolean) => {
    //           if (toolBarsFiltered && !id.includes("-tbMain")) {
    //               return toolBarsFiltered.findIndex(entry => entry[1].id === id) !== (first ? 0 : toolBarsFiltered.length - 1) ? true : false;
    //           }
    //           return true;
    //       }

    //       /** If compSizes is set (every component in this layout reported its preferred size) */
    //       if(compSizes && childrenSorted.size === compSizes.size) {
    //           /**
    //          * Gets the factor for an alignment value. The factor will be used
    //          * to align the components in the layout.
    //            * @param alignment - the alignment
    //            * @returns the factor for an alignment value
    //            */
    //           const getAlignmentFactor = (alignment:number) => {
    //               switch (alignment) {
    //                   case HORIZONTAL_ALIGNMENT.LEFT:
    //                   case VERTICAL_ALIGNMENT.TOP:
    //                       return 0;
    //                   case HORIZONTAL_ALIGNMENT.CENTER:
    //                       return 0.5;
    //                   case HORIZONTAL_ALIGNMENT.RIGHT:
    //                   case VERTICAL_ALIGNMENT.BOTTOM:
    //                       return 1;
    //                   default:
    //                       console.error('Invalid alignment: ' + alignment);
    //                       return 0;
    //               }
    //           }

    //           /** Calculates the grid for the FlowLayout */
    //           const calculateGrid = ():FlowGrid => {
    //               /** Calculated height of the latest column of the FlowLayout */
    //               let calcHeight = 0;
    //               /** Calculated width of the latest row of the FlowLayout */
    //               let calcWidth = 0;

    //               /** The width of the FlowLayout */
    //               let width = 0;
    //               /** The height of the FlowLayout */
    //               let height = 0;
    //               /** The amount of rows in the FlowLayout */
    //               let anzRows = 1;
    //               /** The amount of columns in the FlowLayout */
    //               let anzCols = 1;

    //               /** If the current component is the first */
    //               let bFirst = true;

    //               let tbExtraWidth = toolBarsFiltered ? checkFirstOrLastToolBar(id, false) ? 5 : 0 : 0;

    //               childrenSorted.forEach(component => {
    //                   if (component.visible !== false) {
    //                       const prefSize = compSizes.get(component.id)?.preferredSize || { width: 0, height: 0 };
    //                       if (isRowOrientationHorizontal) {
    //                           /** If this isn't the first component add the gap between components*/
    //                           if (!bFirst) {
    //                               calcWidth += gaps.horizontalGap + toolbarGap;
    //                           }
    //                           calcWidth += prefSize.width;
    //                           /** Check for the tallest component in row orientation */
    //                           height = Math.max(height, prefSize.height);

    //                           /** If autowrapping is true and the width of the row is greater than the width of the layout, add a new row */
    //                           if (!bFirst && autoWrap && (style.width as number) > 0 && calcWidth > (style.width as number)) {
    //                               calcWidth = prefSize.width;
    //                               anzRows++;
    //                           }
    //                           else if (bFirst) {
    //                               bFirst = false;
    //                           }
    //                           /** Check if the current row is wider than the current width of the FlowLayout */
    //                           width = Math.max(width, calcWidth);
    //                       }
    //                       else {
    //                           /** If this isn't the first component add the gap between components*/
    //                           if (!bFirst) {
    //                               calcHeight += gaps.verticalGap + toolbarGap;
    //                           }
    //                           calcHeight += prefSize.height;
    //                           /** Check for the widest component in row orientation */
    //                           width = Math.max(width, prefSize.width);

    //                           /** If autowrapping is true and the height of the column is greater than the height of the layout, add a new column */
    //                           if (!bFirst && autoWrap && (style.height as number) > 0 && calcHeight > (style.height as number)) {
    //                               calcHeight = prefSize.height;
    //                               anzCols++;
    //                           }
    //                           else if (bFirst) {
    //                               bFirst = false;
    //                           }
    //                           /** Check if the current column is taller than the current height of the FlowLayout */
    //                           height = Math.max(height, calcHeight);
    //                       }
    //                   }
    //               });
    //               if (tbExtraWidth !== 0) {
    //                   isRowOrientationHorizontal ? width += tbExtraWidth : height += tbExtraWidth;
    //               }
    //               const grid:FlowGrid = {columns: anzCols, rows: anzRows, gridWidth: width, gridHeight: height}
    //               return grid;
    //           }

    //           const flowLayoutInfo = calculateGrid();
    //           const prefSize:Dimension = { width: (flowLayoutInfo.gridWidth * flowLayoutInfo.columns + gaps.horizontalGap * (flowLayoutInfo.columns-1)) + margins.marginLeft + margins.marginRight,
    //                                        height: (flowLayoutInfo.gridHeight * flowLayoutInfo.rows + gaps.verticalGap * (flowLayoutInfo.rows-1)) + margins.marginTop + margins.marginBottom };
    //           let left:number;
    //           let width:number;

    //           if (outerHa === HORIZONTAL_ALIGNMENT.STRETCH) {
    //               left = margins.marginLeft;
    //               width = (style.width as number);
    //           }
    //           else {
    //               left = ((style.width as number) - prefSize.width) * getAlignmentFactor(outerHa) + margins.marginLeft;
    //               width = prefSize.width;
    //           }

    //           let top:number;
    //           let height:number;

    //           if (outerVa === VERTICAL_ALIGNMENT.STRETCH) {
    //               top = margins.marginTop;
    //               height = (style.height as number);
    //           }
    //           else {
    //               top = ((style.height as number) - prefSize.height) * getAlignmentFactor(outerVa) + margins.marginTop;
    //               height = prefSize.height;
    //           }

    //           if(top < 0 && !alignChildrenIfOverflow) {
    //               top = 0;
    //           }

    //           /** The FlowLayout width */
    //           let fW = Math.max(1, width);
    //           /** The FlowLayout preferred width */
    //           let fPW = Math.max(1, prefSize.width);
    //           /** The FlowLayout preferred height*/
    //           let fH = Math.max(1, height);
    //           /** The FlowLayout preferred height */
    //           let fPH = Math.max(1, prefSize.height);
    //           /** x stores the columns */
    //           let x = 0;
    //           /** y stores the rows */
    //           let y = 0;

    //           let bFirst = true;
    //           /**
    //            * Build the sizemap with each component based on the constraints with their component id as key and css style as value
    //            * Calculations are taken from "JVxSequenceLayout" I don't want to explain something wrong if I maybe misinterpret something
    //            * so I won't put comments in the calculation.
    //            */
    //           childrenSorted.forEach(component => {
    //               if (component.visible !== false) {
    //                   const size = compSizes.get(component.id)?.preferredSize || {width: 0, height: 0};

    //                   if (isRowOrientationHorizontal) {
    //                       if (!bFirst && autoWrap && (style.width as number) > 0 && x + size.width > (style.width as number)) {
    //                           x = 0;
    //                           y += (flowLayoutInfo.gridHeight + gaps.verticalGap) * fH / fPH;

    //                       }

    //                       if (innerAlignment === VERTICAL_ALIGNMENT.STRETCH) {
    //                           sizeMap.set(component.id, {
    //                               left: (left + x * fW / fPW) + (!bFirst ? toolbarGap : 0),
    //                               top: top + y,
    //                               width: size.width * fW / fPW,
    //                               height: flowLayoutInfo.gridHeight * fH / fPH,
    //                               position: "absolute",
    //                               borderRight: id.includes("-tbMain") && checkFirstOrLastToolBar(component.id, false) ? "1px solid #bbb" : ""
    //                           });
    //                       }
    //                       else {
    //                           sizeMap.set(component.id, {
    //                               left: (left + x * fW / fPW) + (!bFirst ? toolbarGap : 0),
    //                               top: top + y + ((flowLayoutInfo.gridHeight - size.height) * getAlignmentFactor(innerAlignment)) * fH / fPH,
    //                               width: size.width * fW / fPW,
    //                               height: size.height * fH / fPH,
    //                               position: "absolute",
    //                               borderRight: id.includes("-tbMain") && checkFirstOrLastToolBar(component.id, false) ? "1px solid #bbb" : ""
    //                           });
    //                       }

    //                       if (bFirst) {
    //                           bFirst = false;
    //                       }

    //                       x += size.width + gaps.horizontalGap;
    //                   }
    //                   else {
    //                       if (!bFirst && autoWrap && (style.height as number) > 0 && y + size.height > (style.height as number)) {
    //                           y = 0;
    //                           x += (flowLayoutInfo.gridWidth + gaps.horizontalGap) * fW / fPW;
    //                       }

    //                       if (innerAlignment === HORIZONTAL_ALIGNMENT.STRETCH) {
    //                           sizeMap.set(component.id, {
    //                               left: left + x,
    //                               top: (top + y * fH / fPH) + (!bFirst ? toolbarGap : 0),
    //                               width: flowLayoutInfo.gridWidth * fW / fPW,
    //                               height: size.height * fH / fPH,
    //                               position: "absolute",
    //                               borderBottom: id.includes("-tbMain") && checkFirstOrLastToolBar(component.id, true) ? "1px solid #bbb" : ""
    //                           });
    //                       }
    //                       else {
    //                           sizeMap.set(component.id, {
    //                               left: left + x + ((flowLayoutInfo.gridWidth - size.width) * getAlignmentFactor(innerAlignment)) * fW / fPW,
    //                               top: (top + y * fH / fPH) + (!bFirst ? toolbarGap : 0),
    //                               width: size.width * fW / fPW,
    //                               height: size.height * fH / fPH,
    //                               position: "absolute",
    //                               borderBottom: id.includes("-tbMain") && checkFirstOrLastToolBar(component.id, true) ? "1px solid #bbb" : ""
    //                           });
    //                       }

    //                       if (bFirst) {
    //                           bFirst = false;
    //                       }

    //                       y += size.height + gaps.verticalGap
    //                   }
    //               }
    //           });

    //           /** If reportSize is set and the layout has not received a size by their parent layout (if possible) or the size of the layout changed, report the size */
    //           if((reportSize && !style.width && !style.height) || (prefSize.height !== style.height || prefSize.width !== style.width)) {
    //               runAfterLayout(() => {
    //                   reportSize({ height: prefSize.height, width: prefSize.width });
    //               });
    //           }
    //           if (baseProps.popupSize) {
    //               setCalculatedStyle({ height: baseProps.popupSize.height, width: baseProps.popupSize.width, position: 'relative', left: toolBarsFiltered?.length ? (checkFirstOrLastToolBar(id, true) && isRowOrientationHorizontal) ? 5 : 0 : 0 });
    //           }
    //           else {
    //               setCalculatedStyle({ height: prefSize.height, width: prefSize.width, position: 'relative', left: toolBarsFiltered?.length ? (checkFirstOrLastToolBar(id, true) && isRowOrientationHorizontal) ? 5 : 0 : 0 })
    //           }
    //       }
    //       return sizeMap;
    //   }, [compSizes, style.width, style.height, reportSize, id, context.contentStore]);

    return HashMap();
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
}
