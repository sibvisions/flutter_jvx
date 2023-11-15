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

import '../model/component/fl_component_model.dart';
import '../model/layout/layout_data.dart';
import '../model/layout/layout_position.dart';
import '../util/i_clonable.dart';
import 'i_layout.dart';

class SplitLayout extends ILayout implements ICloneable {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The first component constraint (left or top).
  static const String FIRST_COMPONENT = "FIRST_COMPONENT";

  /// The second component constraint (right or bottom).
  static const String SECOND_COMPONENT = "SECOND_COMPONENT";

  /// How often a SplitPanelWidget will try to initiate a layout call while dragging.
  static const Duration UPDATE_INTERVAL = Duration(milliseconds: 50);

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
  SplitOrientation splitAlignment;

  LayoutPosition firstComponentViewer = LayoutPosition(
    width: 0,
    height: 0,
    top: 0,
    left: 0,
  );

  Size firstComponentSize = Size.zero;

  LayoutPosition secondComponentViewer = LayoutPosition(
    width: 0,
    height: 0,
    top: 0,
    left: 0,
  );

  Size secondComponentSize = Size.zero;

  bool calculateLikeScroll;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SplitLayout({
    this.splitterSize = 10,
    this.splitAlignment = SplitOrientation.VERTICAL,
    this.leftTopRatio = 50,
    this.calculateLikeScroll = false,
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
    if (position != null) {
      if (splitAlignment == SplitOrientation.VERTICAL) {
        double leftTopWidth = max(
          position.width / 100 * leftTopRatio - splitterSize / 2,
          0.0,
        );
        double rightBottomWidth = max(
          position.width / 100 * (100 - leftTopRatio) - splitterSize / 2,
          0.0,
        );

        firstComponentViewer = LayoutPosition(
          width: leftTopWidth,
          height: position.height,
          top: 0,
          left: 0,
        );
        secondComponentViewer = LayoutPosition(
          width: rightBottomWidth,
          height: position.height,
          top: 0,
          left: leftTopWidth + splitterSize,
        );
      } else {
        double leftTopHeight = max(
          position.height / 100 * leftTopRatio - splitterSize / 2,
          0.0,
        );
        double rightBottomHeight = max(
          position.height / 100 * (100 - leftTopRatio) - splitterSize / 2,
          0.0,
        );

        firstComponentViewer = LayoutPosition(
          width: position.width,
          height: leftTopHeight,
          top: 0,
          left: 0,
        );
        secondComponentViewer = LayoutPosition(
          width: position.width,
          height: rightBottomHeight,
          top: leftTopHeight + splitterSize,
          left: 0,
        );
      }
    }

    if (calculateLikeScroll) {
      firstComponentSize = Size(max(leftTopChild.bestSize.width, firstComponentViewer.width),
          max(leftTopChild.bestSize.height, firstComponentViewer.height));

      leftTopChild.layoutPosition = LayoutPosition(
        width: firstComponentSize.width,
        height: firstComponentSize.height,
        top: 0,
        left: 0,
      );

      secondComponentSize = Size(max(rightBottomChild.bestSize.width, secondComponentViewer.width),
          max(rightBottomChild.bestSize.height, secondComponentViewer.height));

      rightBottomChild.layoutPosition = LayoutPosition(
        width: secondComponentSize.width,
        height: secondComponentSize.height,
        top: 0,
        left: 0,
      );
    } else {
      leftTopChild.layoutPosition = firstComponentViewer;
      rightBottomChild.layoutPosition = secondComponentViewer;
    }

    // preferred width & height
    double width = splitAlignment == SplitOrientation.VERTICAL ? splitterSize : 0;
    double height = splitAlignment == SplitOrientation.HORIZONTAL ? splitterSize : 0;

    for (LayoutData child in pChildren) {
      if (splitAlignment == SplitOrientation.VERTICAL) {
        width += child.bestSize.width;
        height = max(height, child.bestSize.height);
      } else {
        height += child.bestSize.height;
        width = max(width, child.bestSize.width);
      }
    }

    pParent.calculatedSize = Size(width, height);
  }

  @override
  ILayout clone() {
    return SplitLayout(
      leftTopRatio: leftTopRatio,
      splitAlignment: splitAlignment,
      splitterSize: splitterSize,
      calculateLikeScroll: calculateLikeScroll,
    )
      ..firstComponentSize = firstComponentSize
      ..secondComponentSize = secondComponentSize
      ..firstComponentViewer = firstComponentViewer
      ..secondComponentViewer = secondComponentViewer;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "SplitLayout[firstComponentViewer: $firstComponentViewer; secondComponentViewer: $secondComponentViewer]";
  }
}
