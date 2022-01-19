import 'dart:ui';

import 'package:flutter_client/src/layout/i_layout.dart';
import 'package:flutter_client/src/model/component/panel/fl_split_panel.dart';
import 'package:flutter_client/src/model/layout/layout_data.dart';
import 'package:flutter_client/src/model/layout/layout_position.dart';
import 'package:flutter_client/util/i_clonable.dart';

class SplitLayout implements ILayout, ICloneable {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The first component constraint (left or top).
  static const String FIRST_COMPONENT = "FIRST_COMPONENT";

  /// The second component constraint (right or bottom).
  static const String SECOND_COMPONENT = "SECOND_COMPONENT";



  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Ratio of how much of the available space is reserved for the left/top panel.
  /// 100 equals all of the available space and 0 equals none.
  /// Defaults to 50
  double leftTopRatio;

  /// Size of the splitter, defaults to 10
  double splitterSize;

  /// How the splitter is orientated, defaults to Vertical
  SPLIT_ORIENTATION splitAlignment;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SplitLayout({
    this.splitterSize = 10,
    this.splitAlignment = SPLIT_ORIENTATION.VERTICAL,
    this.leftTopRatio = 50
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void calculateLayout(LayoutData pParent, List<LayoutData> pChildren) {
    // Either left or top child, dependent on splitter orientation
    LayoutData leftTopChild = pChildren.firstWhere((element) => element.constraints == FIRST_COMPONENT);
    // Either right or bottom child, dependent on splitter orientation
    LayoutData rightBottomChild = pChildren.firstWhere((element) => element.constraints == SECOND_COMPONENT);

    LayoutPosition? position = pParent.layoutPosition;

    // Only set position on children if layout has a position set.
    if(position != null){
      if(splitAlignment == SPLIT_ORIENTATION.VERTICAL){
        double leftTopWidth = position.width/100*leftTopRatio-splitterSize/2;
        double rightBottomWidth = position.width/100*(1-(leftTopRatio/100))-splitterSize/2;

        leftTopChild.layoutPosition = LayoutPosition(
            width: leftTopWidth.ceilToDouble(),
            height: position.height,
            top: 0,
            left: 0,
            isComponentSize: true
        );
        rightBottomChild.layoutPosition = LayoutPosition(
            width: rightBottomWidth.ceilToDouble(),
            height: position.height,
            top: 0,
            left: leftTopWidth+splitterSize,
            isComponentSize: true
        );
      } else {
        double leftTopHeight = position.height/100*leftTopRatio-splitterSize/2;
        double rightBottomHeight = position.height/100*(1-(leftTopRatio/100))-splitterSize/2;

        leftTopChild.layoutPosition = LayoutPosition(
            width: position.width,
            height: leftTopHeight,
            top: 0,
            left: 0,
            isComponentSize: true
        );
        rightBottomChild.layoutPosition = LayoutPosition(
            width: position.width,
            height: rightBottomHeight,
            top: leftTopHeight + splitterSize,
            left: 0,
            isComponentSize: true
        );
      }

      // Split layout can never exceed its given size (position).
      if(pParent.isWidthNewlyConstraint){
        pParent.widthConstrains[pParent.layoutPosition!.width] = position.height;
      }
      if(pParent.isHeightNewlyConstraint){
        pParent.heightConstrains[pParent.layoutPosition!.height] = position.width;
      }
    } else {
      // preferred width & height
      double width = splitAlignment == SPLIT_ORIENTATION.VERTICAL ? splitterSize : 0;
      double height = splitAlignment == SPLIT_ORIENTATION.HORIZONTAL ? splitterSize : 0;
      for(LayoutData child in pChildren){
        width += child.bestSize.width;
        height += child.bestSize.height;
      }
      pParent.calculatedSize = Size(width, height);
    }

  }

  @override
  ILayout clone() {
    return SplitLayout(leftTopRatio: leftTopRatio, splitAlignment: splitAlignment, splitterSize: splitterSize);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

}