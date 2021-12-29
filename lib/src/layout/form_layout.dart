import 'dart:collection';
import 'dart:core';
import 'dart:developer';

import 'package:flutter/material.dart';
import '../model/layout/alignments.dart';

import '../../util/layout/form_layout/fl_calculate_anchors_util.dart';
import '../../util/layout/form_layout/fl_calculate_dependent_util.dart';
import '../model/layout/form_layout/form_layout_anchor.dart';
import '../model/layout/form_layout/form_layout_constraints.dart';
import '../model/layout/form_layout/form_layout_size.dart';
import '../model/layout/form_layout/form_layout_used_border.dart';
import '../model/layout/gaps.dart';
import '../model/layout/margins.dart';
import '../model/layout/layout_data.dart';
import '../model/layout/layout_position.dart';
import 'i_layout.dart';

class FormLayout extends ILayout {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The original layout string
  final String layoutString;

  /// The split layout string.
  final List<String> splitLayoutString;

  /// The original layout data string
  final String layoutData;

  /// Margins
  late final Margins margins;

  /// Gaps
  late final Gaps gaps;

  /// Raw alignments
  late final List<String> alignment;

  /// Horizontal alignment
  late final HorizontalAlignment horizontalAlignment;

  /// Vertical alignment
  late final VerticalAlignment verticalAlignment;

  /// Anchors
  late final HashMap<String, FormLayoutAnchor> anchors;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FormLayout({required this.layoutData, required this.layoutString}) : splitLayoutString = layoutString.split(",") {
    margins = Margins.fromList(marginList: splitLayoutString.sublist(1, 5));
    gaps = Gaps.createFromList(gapsList: splitLayoutString.sublist(5, 7));
    alignment = splitLayoutString.sublist(7, 9);
    anchors = _getAnchors(layoutData);
    horizontalAlignment = HorizontalAlignmentE.fromString(alignment[0]);
    verticalAlignment = VerticalAlignmentE.fromString(alignment[1]);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  ILayout clone() {
    return FormLayout(layoutData: layoutData, layoutString: layoutString);
  }

  @override
  void calculateLayout(LayoutData pParent, List<LayoutData> pChildren) {
    /// Size set by Parent
    final Size? setPosition = _getSize(pParent);

    /// Component constraints
    HashMap<String, FormLayoutConstraints> componentConstraints = _getComponentConstraints(pChildren, anchors);

    FormLayoutUsedBorder usedBorder = FormLayoutUsedBorder();
    FormLayoutSize preferredMinimumSize = FormLayoutSize();

    _calculateAnchors(
        pAnchors: anchors,
        pComponentData: pChildren,
        pComponentConstraints: componentConstraints,
        pUsedBorder: usedBorder,
        pPreferredMinimumSize: preferredMinimumSize,
        pGaps: gaps);

    _calculateTargetDependentAnchors(
        pMinPrefSize: preferredMinimumSize,
        pAnchors: anchors,
        pHorizontalAlignment: horizontalAlignment,
        pVerticalAlignment: verticalAlignment,
        pUsedBorder: usedBorder,
        pMargins: margins,
        pComponentData: pChildren,
        pComponentConstraints: componentConstraints,
        pGivenSize: setPosition);

    return _buildComponents(
        pAnchors: anchors,
        pComponentConstraints: componentConstraints,
        pMargins: margins,
        id: pParent.id,
        pChildrenData: pChildren,
        pParent: pParent,
        pMinPrefSize: preferredMinimumSize);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Size? _getSize(LayoutData pParent) {
    double dimWidth;
    double dimHeight;

    if (pParent.hasPreferredSize) {
      dimWidth = pParent.preferredSize!.width;
      dimHeight = pParent.preferredSize!.height;
    } else if (pParent.hasCalculatedSize &&
        pParent.hasPosition &&
        pParent.calculatedSize!.width != double.infinity &&
        pParent.calculatedSize!.height != double.infinity) {
      dimWidth = pParent.layoutPosition!.width;
      dimHeight = pParent.layoutPosition!.height;
    } else if (pParent.hasCalculatedSize) {
      dimWidth = pParent.calculatedSize!.width != double.infinity ? pParent.calculatedSize!.width : 0.0;
      dimHeight = pParent.calculatedSize!.height != double.infinity ? pParent.calculatedSize!.height : 0.0;
    } else {
      dimWidth = 0.0;
      dimHeight = 0.0;
    }

    if (dimHeight == 0.0 && dimWidth == 0.0) {
      return null;
    }

    return Size(dimWidth, dimHeight);
  }

  void _calculateAnchors(
      {required HashMap<String, FormLayoutAnchor> pAnchors,
      required List<LayoutData> pComponentData,
      required HashMap<String, FormLayoutConstraints> pComponentConstraints,
      required FormLayoutUsedBorder pUsedBorder,
      required FormLayoutSize pPreferredMinimumSize,
      required Gaps pGaps}) {
    FLCalculateAnchorsUtil.clearAutoSize(pAnchors: pAnchors);

    // Init autoSize Anchor position
    pAnchors.forEach((anchorName, anchor) {
      // Check if two autoSize anchors are side by side
      if (anchor.relatedAnchor != null && anchor.relatedAnchor!.autoSize) {
        FormLayoutAnchor relatedAutoSizeAnchor = anchor.relatedAnchor!;
        if (relatedAutoSizeAnchor.relatedAnchor != null && !relatedAutoSizeAnchor.relatedAnchor!.autoSize) {
          relatedAutoSizeAnchor.position = -anchor.position;
        }
      }
    });

    // Init autoSize Anchors
    for (var component in pComponentData) {
      FormLayoutConstraints constraint = pComponentConstraints[component.id]!;

      FLCalculateAnchorsUtil.initAutoSizeRelative(
          pStartAnchor: constraint.leftAnchor, pEndAnchor: constraint.rightAnchor, pAnchors: pAnchors);
      FLCalculateAnchorsUtil.initAutoSizeRelative(
          pStartAnchor: constraint.rightAnchor, pEndAnchor: constraint.leftAnchor, pAnchors: pAnchors);
      FLCalculateAnchorsUtil.initAutoSizeRelative(
          pStartAnchor: constraint.topAnchor, pEndAnchor: constraint.bottomAnchor, pAnchors: pAnchors);
      FLCalculateAnchorsUtil.initAutoSizeRelative(
          pStartAnchor: constraint.bottomAnchor, pEndAnchor: constraint.topAnchor, pAnchors: pAnchors);
    }

    // AutoSize calculations
    for (double autoSizeCount = 1; autoSizeCount > 0 && autoSizeCount < 10000000;) {
      for (var component in pComponentData) {
        FormLayoutConstraints constraint = pComponentConstraints[component.id]!;
        Size preferredSize = component.bestSize;
        FLCalculateAnchorsUtil.calculateAutoSize(
            pLeftTopAnchor: constraint.topAnchor,
            pRightBottomAnchor: constraint.bottomAnchor,
            pPreferredSize: preferredSize.height,
            pAutoSizeCount: autoSizeCount,
            pAnchors: pAnchors);
        FLCalculateAnchorsUtil.calculateAutoSize(
            pLeftTopAnchor: constraint.leftAnchor,
            pRightBottomAnchor: constraint.rightAnchor,
            pPreferredSize: preferredSize.width,
            pAutoSizeCount: autoSizeCount,
            pAnchors: pAnchors);
      }
      autoSizeCount = 10000000;

      for (var component in pComponentData) {
        FormLayoutConstraints constraint = pComponentConstraints[component.id]!;

        double count;
        count = FLCalculateAnchorsUtil.finishAutoSizeCalculation(
            leftTopAnchor: constraint.leftAnchor, rightBottomAnchor: constraint.rightAnchor, pAnchors: pAnchors);
        if (count > 0 && count < autoSizeCount) {
          log("1st");
          autoSizeCount = count;
        }
        count = FLCalculateAnchorsUtil.finishAutoSizeCalculation(
            leftTopAnchor: constraint.rightAnchor, rightBottomAnchor: constraint.leftAnchor, pAnchors: pAnchors);
        if (count > 0 && count < autoSizeCount) {
          log("2nd");
          autoSizeCount = count;
        }
        count = FLCalculateAnchorsUtil.finishAutoSizeCalculation(
            leftTopAnchor: constraint.topAnchor, rightBottomAnchor: constraint.bottomAnchor, pAnchors: pAnchors);
        if (count > 0 && count < autoSizeCount) {
          log("3rd");
          autoSizeCount = count;
        }
        count = FLCalculateAnchorsUtil.finishAutoSizeCalculation(
            leftTopAnchor: constraint.bottomAnchor, rightBottomAnchor: constraint.topAnchor, pAnchors: pAnchors);
        if (count > 0 && count < autoSizeCount) {
          log("4th");
          autoSizeCount = count;
        }
      }
    }

    double leftWidth = 0;
    double rightWidth = 0;
    double topHeight = 0;
    double bottomHeight = 0;

    // Calculate preferredSize
    for (var component in pComponentData) {
      FormLayoutConstraints constraint = pComponentConstraints[component.id]!;

      Size preferredComponentSize = component.bestSize;
      Size minimumComponentSize = component.minSize ?? const Size(0, 0);

      if (constraint.rightAnchor.getBorderAnchor().name == "l") {
        double w = constraint.rightAnchor.getAbsolutePosition();
        if (w > leftWidth) {
          leftWidth = w;
        }
        pUsedBorder.leftBorderUsed = true;
      }
      if (constraint.leftAnchor.getBorderAnchor().name == "r") {
        double w = -constraint.leftAnchor.getAbsolutePosition();
        if (w > rightWidth) {
          rightWidth = w;
        }
        pUsedBorder.rightBorderUsed = true;
      }
      if (constraint.bottomAnchor.getBorderAnchor().name == "t") {
        double h = constraint.bottomAnchor.getAbsolutePosition();
        if (h > topHeight) {
          topHeight = h;
        }
        pUsedBorder.topBorderUsed = true;
      }
      if (constraint.topAnchor.getBorderAnchor().name == "b") {
        double h = -constraint.topAnchor.getAbsolutePosition();
        if (h > bottomHeight) {
          topHeight = h;
        }
        pUsedBorder.bottomBorderUsed = true;
      }

      if (constraint.leftAnchor.getBorderAnchor().name == "l" && constraint.rightAnchor.getBorderAnchor().name == "r") {
        if (!constraint.leftAnchor.autoSize || !constraint.rightAnchor.autoSize) {
          double w = constraint.leftAnchor.getAbsolutePosition() -
              constraint.rightAnchor.getAbsolutePosition() +
              preferredComponentSize.width;
          if (w > pPreferredMinimumSize.preferredWidth) {
            pPreferredMinimumSize.preferredWidth = w;
          }
          w = constraint.leftAnchor.getAbsolutePosition() -
              constraint.rightAnchor.getAbsolutePosition() +
              minimumComponentSize.width;
          if (w > pPreferredMinimumSize.minimumWidth) {
            pPreferredMinimumSize.minimumWidth;
          }
        }
        pUsedBorder.leftBorderUsed = true;
        pUsedBorder.rightBorderUsed = true;
      }
      if (constraint.topAnchor.getBorderAnchor().name == "t" && constraint.bottomAnchor.getBorderAnchor().name == "b") {
        if (!constraint.topAnchor.autoSize || !constraint.bottomAnchor.autoSize) {
          double h = constraint.topAnchor.getAbsolutePosition() -
              constraint.bottomAnchor.getAbsolutePosition() +
              preferredComponentSize.height;
          if (h > pPreferredMinimumSize.preferredHeight) {
            pPreferredMinimumSize.preferredHeight = h;
          }
          h = constraint.topAnchor.getAbsolutePosition() -
              constraint.bottomAnchor.getAbsolutePosition() +
              minimumComponentSize.height;
          if (h > pPreferredMinimumSize.minimumHeight) {
            pPreferredMinimumSize.minimumHeight = h;
          }
        }
        pUsedBorder.topBorderUsed = true;
        pUsedBorder.bottomBorderUsed = true;
      }
    }

    //----------------------------------------------------------

    /// Preferred width
    if (leftWidth != 0 && rightWidth != 0) {
      double w = leftWidth + rightWidth + pGaps.horizontalGap;
      if (w > pPreferredMinimumSize.preferredWidth) {
        pPreferredMinimumSize.preferredWidth = w;
      }
      if (w > pPreferredMinimumSize.minimumWidth) {
        pPreferredMinimumSize.minimumWidth = w;
      }
    } else if (leftWidth != 0) {
      FormLayoutAnchor rma = pAnchors["rm"]!;
      double w = leftWidth - rma.position;
      if (w > pPreferredMinimumSize.preferredWidth) {
        pPreferredMinimumSize.preferredWidth = w;
      }
      if (w > pPreferredMinimumSize.minimumWidth) {
        pPreferredMinimumSize.minimumWidth = w;
      }
    } else {
      FormLayoutAnchor lma = pAnchors["lm"]!;
      double w = rightWidth + lma.position;
      if (w > pPreferredMinimumSize.preferredWidth) {
        pPreferredMinimumSize.preferredWidth = w;
      }
      if (w > pPreferredMinimumSize.minimumWidth) {
        pPreferredMinimumSize.minimumWidth = w;
      }
    }

    /// Preferred height
    if (topHeight != 0 && bottomHeight != 0) {
      double h = topHeight + bottomHeight + pGaps.verticalGap;
      if (h > pPreferredMinimumSize.preferredHeight) {
        pPreferredMinimumSize.preferredHeight = h;
      }
      if (h > pPreferredMinimumSize.minimumHeight) {
        pPreferredMinimumSize.minimumHeight = h;
      }
    } else if (topHeight != 0) {
      FormLayoutAnchor bma = pAnchors["bm"]!;
      double h = topHeight - bma.position;
      if (h > pPreferredMinimumSize.preferredHeight) {
        pPreferredMinimumSize.preferredHeight = h;
      }
      if (h > pPreferredMinimumSize.minimumHeight) {
        pPreferredMinimumSize.minimumHeight = h;
      }
    } else {
      FormLayoutAnchor tma = pAnchors["tm"]!;
      double h = bottomHeight + tma.position;
      if (h > pPreferredMinimumSize.preferredHeight) {
        pPreferredMinimumSize.preferredHeight = h;
      }
      if (h > pPreferredMinimumSize.minimumHeight) {
        pPreferredMinimumSize.minimumHeight;
      }
    }
  }

  void _calculateTargetDependentAnchors(
      {required FormLayoutSize pMinPrefSize,
      required HashMap<String, FormLayoutAnchor> pAnchors,
      required HorizontalAlignment pHorizontalAlignment,
      required VerticalAlignment pVerticalAlignment,
      required FormLayoutUsedBorder pUsedBorder,
      required Margins pMargins,
      required List<LayoutData> pComponentData,
      required HashMap<String, FormLayoutConstraints> pComponentConstraints,
      Size? pGivenSize}) {
    /// ToDo SetSizes from server
    Size maxLayoutSize = const Size(10000, 10000);
    Size minLayoutSize = const Size(50, 50);

    /// Available Size, set to setSize from parent by default
    Size calcSize = pGivenSize ?? Size(pMinPrefSize.minimumWidth, pMinPrefSize.minimumHeight);

    /// Not smaller than Minimum
    // double newMinWidth = calcSize.width;
    // double newMinHeight = calcSize.height;
    // if(newMinWidth < pMinPrefSize.minimumWidth){
    //   newMinWidth = pMinPrefSize.minimumWidth;
    // }
    // if(newMinHeight < pMinPrefSize.minimumHeight) {
    //   newMinHeight = pMinPrefSize.minimumHeight;
    // }
    // calcSize = Size(newMinWidth, newMinHeight);
    //
    // /// Not bigger than maximumSize (from Server)
    // if(setSize != null){
    //   double newMaxWidth = calcSize.width;
    //   double newMaxHeight = calcSize.height;
    //   if(calcSize.width > setSize.width){
    //     newMinWidth = setSize.width;
    //   }
    //   if(calcSize.height > setSize.height){
    //     newMaxHeight = setSize.height;
    //   }
    //   calcSize = Size(newMaxWidth, newMaxHeight);
    // }

    FormLayoutAnchor lba = pAnchors["l"]!;
    FormLayoutAnchor rba = pAnchors["r"]!;
    FormLayoutAnchor bba = pAnchors["b"]!;
    FormLayoutAnchor tba = pAnchors["t"]!;

    // Horizontal Alignment
    if (pHorizontalAlignment == HorizontalAlignment.STRETCH ||
        (pUsedBorder.leftBorderUsed && pUsedBorder.rightBorderUsed)) {
      if (minLayoutSize.width > calcSize.width) {
        lba.position = 0;
        rba.position = minLayoutSize.width;
      } else if (maxLayoutSize.width < calcSize.width) {
        switch (pHorizontalAlignment) {
          case HorizontalAlignment.LEFT:
            lba.position = 0;
            break;
          case HorizontalAlignment.RIGHT:
            lba.position = calcSize.width - maxLayoutSize.width;
            break;
          default:
            lba.position = (calcSize.width - maxLayoutSize.width) / 2;
        }
        lba.position = lba.position + maxLayoutSize.width;
      } else {
        lba.position = 0;
        rba.position = calcSize.width;
      }
    } else {
      if (pMinPrefSize.preferredWidth > calcSize.width) {
        lba.position = 0;
      } else {
        switch (pHorizontalAlignment) {
          case HorizontalAlignment.LEFT:
            lba.position = 0;
            break;
          case HorizontalAlignment.RIGHT:
            lba.position = calcSize.width - pMinPrefSize.preferredWidth;
            break;
          default:
            lba.position = (calcSize.width - pMinPrefSize.preferredWidth) / 2;
        }
        rba.position = lba.position + pMinPrefSize.preferredWidth;
      }
    }

    // Vertical Alignment
    if (pVerticalAlignment == VerticalAlignment.STRETCH ||
        (pUsedBorder.bottomBorderUsed && pUsedBorder.topBorderUsed)) {
      if (minLayoutSize.height > calcSize.height) {
        tba.position = 0;
        bba.position = minLayoutSize.height;
      } else if (maxLayoutSize.height < calcSize.height) {
        switch (pVerticalAlignment) {
          case VerticalAlignment.TOP:
            tba.position = 0;
            break;
          case VerticalAlignment.BOTTOM:
            tba.position = calcSize.height - maxLayoutSize.height;
            break;
          default:
            tba.position = (calcSize.height - maxLayoutSize.height) / 2;
        }
        bba.position = tba.position + maxLayoutSize.height;
      } else {
        tba.position = 0;
        bba.position = calcSize.height;
      }
    } else {
      if (pMinPrefSize.preferredHeight > calcSize.height) {
        tba.position = 0;
      } else {
        switch (pVerticalAlignment) {
          case VerticalAlignment.TOP:
            tba.position = 0;
            break;
          case VerticalAlignment.BOTTOM:
            tba.position = calcSize.height - pMinPrefSize.preferredHeight;
            break;
          default:
            tba.position = (calcSize.height - pMinPrefSize.preferredHeight) / 2;
        }
        bba.position = tba.position + pMinPrefSize.preferredHeight;
      }
    }

    lba.position -= pMargins.marginLeft;
    rba.position -= pMargins.marginLeft;
    tba.position -= pMargins.marginTop;
    bba.position -= pMargins.marginTop;

    for (var component in pComponentData) {
      FormLayoutConstraints constraints = pComponentConstraints[component.id]!;
      Size preferredComponentSize = component.bestSize;
      FLCalculateDependentUtil.calculateRelativeAnchor(
          leftTopAnchor: constraints.leftAnchor,
          rightBottomAnchor: constraints.rightAnchor,
          preferredSize: preferredComponentSize.width);
      FLCalculateDependentUtil.calculateRelativeAnchor(
          leftTopAnchor: constraints.topAnchor,
          rightBottomAnchor: constraints.bottomAnchor,
          preferredSize: preferredComponentSize.height);
    }
  }

  void _buildComponents(
      {required HashMap<String, FormLayoutAnchor> pAnchors,
      required HashMap<String, FormLayoutConstraints> pComponentConstraints,
      required Margins pMargins,
      required String id,
      required List<LayoutData> pChildrenData,
      required LayoutData pParent,
      required FormLayoutSize pMinPrefSize}) {
    /// Get Border- and Margin Anchors for calculation
    FormLayoutAnchor lba = pAnchors["l"]!;
    FormLayoutAnchor rba = pAnchors["r"]!;
    FormLayoutAnchor tba = pAnchors["t"]!;
    FormLayoutAnchor bba = pAnchors["b"]!;

    FormLayoutAnchor tma = pAnchors["tm"]!;
    FormLayoutAnchor bma = pAnchors["bm"]!;
    FormLayoutAnchor lma = pAnchors["lm"]!;
    FormLayoutAnchor rma = pAnchors["rm"]!;

    /// Used for components
    FormLayoutConstraints marginConstraints =
        FormLayoutConstraints(bottomAnchor: bma, leftAnchor: lma, rightAnchor: rma, topAnchor: tma);

    /// Used for layoutSize
    FormLayoutConstraints borderConstraints =
        FormLayoutConstraints(bottomAnchor: bba, leftAnchor: lba, rightAnchor: rba, topAnchor: tba);

    // This layout has additional margins to add.
    double additionalLeft = marginConstraints.leftAnchor.getAbsolutePosition();
    double additionalTop = marginConstraints.topAnchor.getAbsolutePosition();

    pComponentConstraints.forEach((componentId, constraint) {
      double left = constraint.leftAnchor.getAbsolutePosition() -
          marginConstraints.leftAnchor.getAbsolutePosition() +
          pMargins.marginLeft +
          additionalLeft;

      double top = constraint.topAnchor.getAbsolutePosition() -
          marginConstraints.topAnchor.getAbsolutePosition() +
          pMargins.marginTop +
          additionalTop;

      double width = constraint.rightAnchor.getAbsolutePosition() - constraint.leftAnchor.getAbsolutePosition();
      double height = constraint.bottomAnchor.getAbsolutePosition() - constraint.topAnchor.getAbsolutePosition();

      LayoutData layoutData = pChildrenData.firstWhere((element) => element.id == componentId);

      ILayout.markForRedrawIfNeeded(layoutData, Size.fromWidth(width));

      layoutData.layoutPosition = LayoutPosition(width: width, height: height, isComponentSize: true, left: left, top: top, timeOfCall: DateTime.now());
    });
    pParent.calculatedSize = Size(pMinPrefSize.preferredWidth, pMinPrefSize.preferredHeight);
  }

  /// Parses all anchors from layoutData and establishes relatedAnchors
  static HashMap<String, FormLayoutAnchor> _getAnchors(String layoutData) {
    HashMap<String, FormLayoutAnchor> anchors = HashMap();

    // Parse layoutData to get Anchors
    final List<String> splitAnchors = layoutData.split(";");
    for (var stringAnchor in splitAnchors) {
      String name = stringAnchor.substring(0, stringAnchor.indexOf(","));
      anchors[name] = FormLayoutAnchor.fromAnchorData(pAnchorData: stringAnchor);
    }

    // Establish relatedAnchors
    anchors.forEach((anchorName, anchor) {
      anchor.relatedAnchor = anchors[anchor.relatedAnchorName];
    });
    return anchors;
  }

  /// Creates [FormLayoutConstraints] for every [LayoutData] (child)
  static HashMap<String, FormLayoutConstraints> _getComponentConstraints(
      List<LayoutData> components, HashMap<String, FormLayoutAnchor> anchors) {
    HashMap<String, FormLayoutConstraints> componentConstraints = HashMap();

    for (var value in components) {
      List<String> anchorNames = value.constraints!.split(";");
      // Get Anchors
      FormLayoutAnchor topAnchor = anchors[anchorNames[0]]!;
      FormLayoutAnchor leftAnchor = anchors[anchorNames[1]]!;
      FormLayoutAnchor bottomAnchor = anchors[anchorNames[2]]!;
      FormLayoutAnchor rightAnchor = anchors[anchorNames[3]]!;
      // Build Constraint
      FormLayoutConstraints constraint = FormLayoutConstraints(
          bottomAnchor: bottomAnchor, leftAnchor: leftAnchor, rightAnchor: rightAnchor, topAnchor: topAnchor);
      componentConstraints[value.id] = constraint;
    }
    return componentConstraints;
  }
}
