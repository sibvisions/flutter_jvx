import 'dart:math';
import 'dart:ui';

import '../../util/i_clonable.dart';
import '../model/component/panel/fl_split_panel_model.dart';
import '../model/layout/layout_data.dart';
import '../model/layout/layout_position.dart';
import 'i_layout.dart';

class SplitLayout implements ILayout, ICloneable {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The first component constraint (left or top).
  static const String FIRST_COMPONENT = "FIRST_COMPONENT";

  /// The second component constraint (right or bottom).
  static const String SECOND_COMPONENT = "SECOND_COMPONENT";

  static const Duration UPDATE_INTERVALL = Duration(milliseconds: 16);
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

  LayoutPosition firstComponentViewer = LayoutPosition(width: 0, height: 0, top: 0, left: 0, isComponentSize: true);

  Size firstComponentSize = Size.zero;

  LayoutPosition secondComponentViewer = LayoutPosition(width: 0, height: 0, top: 0, left: 0, isComponentSize: true);

  Size secondComponentSize = Size.zero;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SplitLayout({this.splitterSize = 10, this.splitAlignment = SPLIT_ORIENTATION.VERTICAL, this.leftTopRatio = 50});

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
    if (position != null) {
      if (splitAlignment == SPLIT_ORIENTATION.VERTICAL) {
        double leftTopWidth = position.width / 100 * leftTopRatio - splitterSize / 2;
        double rightBottomWidth = position.width / 100 * (100 - leftTopRatio) - splitterSize / 2;

        firstComponentViewer = LayoutPosition(
            width: leftTopWidth.ceilToDouble(), height: position.height, top: 0, left: 0, isComponentSize: false);
        secondComponentViewer = LayoutPosition(
            width: rightBottomWidth.ceilToDouble(),
            height: position.height,
            top: 0,
            left: leftTopWidth + splitterSize,
            isComponentSize: false);
      } else {
        double leftTopHeight = position.height / 100 * leftTopRatio - splitterSize / 2;
        double rightBottomHeight = position.height / 100 * (100 - leftTopRatio) - splitterSize / 2;

        firstComponentViewer =
            LayoutPosition(width: position.width, height: leftTopHeight, top: 0, left: 0, isComponentSize: false);
        secondComponentViewer = LayoutPosition(
            width: position.width,
            height: rightBottomHeight,
            top: leftTopHeight + splitterSize,
            left: 0,
            isComponentSize: false);
      }
    }

    firstComponentSize = Size(max(leftTopChild.bestSize.width, firstComponentViewer.width),
        max(leftTopChild.bestSize.height, firstComponentViewer.height));

    leftTopChild.layoutPosition = LayoutPosition(
        width: firstComponentSize.width, height: firstComponentSize.height, top: 0, left: 0, isComponentSize: true);

    secondComponentSize = Size(max(rightBottomChild.bestSize.width, secondComponentViewer.width),
        max(rightBottomChild.bestSize.height, secondComponentViewer.height));

    rightBottomChild.layoutPosition = LayoutPosition(
        width: secondComponentSize.width, height: secondComponentSize.height, top: 0, left: 0, isComponentSize: true);

    // preferred width & height
    double width = splitAlignment == SPLIT_ORIENTATION.VERTICAL ? splitterSize : 0;
    double height = splitAlignment == SPLIT_ORIENTATION.HORIZONTAL ? splitterSize : 0;
    for (LayoutData child in pChildren) {
      width += child.bestSize.width;
      height += child.bestSize.height;
    }

    pParent.calculatedSize = Size(width, height);
  }

  @override
  ILayout clone() {
    var clone = SplitLayout(leftTopRatio: leftTopRatio, splitAlignment: splitAlignment, splitterSize: splitterSize);
    clone.firstComponentSize = firstComponentSize;
    clone.secondComponentSize = secondComponentSize;
    clone.firstComponentViewer = firstComponentViewer;
    clone.secondComponentViewer = secondComponentViewer;
    return clone;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "SplitLayout[leftTopRatio: $leftTopRatio, splitAlignment: $splitAlignment, splitterSize: $splitterSize, firstComponentViewer: $firstComponentViewer, firstComponentSize: $firstComponentSize, secondComponentViewer: $secondComponentViewer, secondComponentSize: $secondComponentSize]";
  }
}
