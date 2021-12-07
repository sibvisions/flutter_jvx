import 'dart:collection';
import 'dart:core';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/layout/form_layout/form_layout_anchor.dart';
import 'package:flutter_client/src/model/layout/form_layout/form_layout_constraints.dart';
import 'package:flutter_client/src/model/layout/form_layout/form_layout_size.dart';
import 'package:flutter_client/src/model/layout/form_layout/gaps.dart';
import 'package:flutter_client/src/model/layout/form_layout/margins.dart';
import 'package:flutter_client/src/model/layout/form_layout/form_layout_used_border.dart';
import 'package:flutter_client/util/layout/form_layout/fl_calculate_anchors_util.dart';
import 'package:flutter_client/util/layout/form_layout/fl_calculate_dependent_util.dart';
import 'package:flutter_client/util/layout/form_layout/fl_util.dart';

import 'i_layout.dart';
import '../model/layout/layout_data.dart';
import '../model/layout/layout_position.dart';

/// Possible Horizontal Alignments (left=0,center=1,right=2,stretch=3)
enum HorizontalAlignment { left, center, right, stretch }

/// Possible Vertical Alignments (top=0,center=1,bottom=2,stretch=3)
enum VerticalAlignment { top, center, bottom, stretch }

class FormLayout extends ILayout {
  @override
  Map<String, LayoutPosition> calculateLayout(LayoutData pParent) {
    // Needed from Outside

    /// Data of children components
    final HashMap<String, LayoutData> componentData = HashMap();

    LayoutData button1 = LayoutData(id: "B102", constraints: "t1;l1;b1;r1", preferredSize: const Size(80, 25));
    LayoutData button2 = LayoutData(id: "B151", constraints: "t3;l1;b3;r1", preferredSize: const Size(80, 25));
    componentData[button1.id] = button1;
    componentData[button2.id] = button2;

    /// LayoutData, Anchor String
    const String layoutData =
        "b0,tm,-,0,0;b1,t1,-,a,0;b2,t2,-,0,0;tm,t,-,10,10;t,-,-,0,0;l1,r0,-,0,0;bm,b,-,-10,-10;b,-,-,0,0;b3,t3,-,a,0;r0,lm,-,0,0;r1,l1,-,a,0;t3,b2,-,0,0;t1,b0,-,0,0;t2,b1,-,5,5;r,-,-,0,0;rm,r,-,-10,-10;lm,l,-,10,10;l,-,-,0,0";

    /// LayoutString
    const String layout = "FormLayout,10,10,10,10,10,5,1,1";

    /// Position set by Parent
    final LayoutPosition? setPosition =
        LayoutPosition(height: 1080, width: 1920, top: 0, left: 0, isComponentSize: false);

    // init and derived variables

    /// Margins
    final Margins margins =
        Margins.fromList(marginList: layout.substring(layout.indexOf(",") + 1, layout.length).split(",").sublist(0, 4));

    /// Gaps
    final Gaps gaps = Gaps.createFromList(
        gapsList: layout.substring(layout.indexOf(",") + 1, layout.length).split(",").sublist(4, 6));

    /// Raw alignments
    final List<String> alignment = layout.substring(layout.indexOf(",") + 1, layout.length).split(",").sublist(6, 8);

    /// Horizontal alignment
    final HorizontalAlignment horizontalAlignment = FLUtil.getHorizontalAlignment(alignment[0]);

    /// Vertical alignment
    final VerticalAlignment verticalAlignment = FLUtil.getVerticalAlignment(alignment[1]);

    /// Anchors
    HashMap<String, FormLayoutAnchor> anchors = FLUtil.getAnchors(layoutData);

    /// Component constraints
    HashMap<String, FormLayoutConstraints> componentConstraints =
        FLUtil.getComponentConstraints(componentData, anchors);

    FormLayoutUsedBorder usedBorder = FormLayoutUsedBorder();
    FormLayoutSize preferredMinimumSize = FormLayoutSize();

    calculateAnchors(
        pAnchors: anchors,
        pComponentData: componentData,
        pComponentConstraints: componentConstraints,
        pUsedBorder: usedBorder,
        pPreferredMinimumSize: preferredMinimumSize,
        pGaps: gaps);

    calculateTargetDependentAnchors(
        pMinPrefSize: preferredMinimumSize,
        pAnchors: anchors,
        pHorizontalAlignment: horizontalAlignment,
        pVerticalAlignment: verticalAlignment,
        pUsedBorder: usedBorder,
        pMargins: margins,
        pComponentData: componentData,
        pComponentConstraints: componentConstraints,
        pGivenSize: setPosition);

    buildComponents(pAnchors: anchors, pComponentConstraints: componentConstraints, pMargins: margins);

    return {};
  }

  void calculateAnchors(
      {required HashMap<String, FormLayoutAnchor> pAnchors,
      required HashMap<String, LayoutData> pComponentData,
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
    pComponentData.forEach((componentId, component) {
      FormLayoutConstraints constraint = pComponentConstraints[componentId]!;

      FLCalculateAnchorsUtil.initAutoSizeRelative(
          pStartAnchor: constraint.leftAnchor, pEndAnchor: constraint.rightAnchor, pAnchors: pAnchors);
      FLCalculateAnchorsUtil.initAutoSizeRelative(
          pStartAnchor: constraint.rightAnchor, pEndAnchor: constraint.leftAnchor, pAnchors: pAnchors);
      FLCalculateAnchorsUtil.initAutoSizeRelative(
          pStartAnchor: constraint.topAnchor, pEndAnchor: constraint.bottomAnchor, pAnchors: pAnchors);
      FLCalculateAnchorsUtil.initAutoSizeRelative(
          pStartAnchor: constraint.bottomAnchor, pEndAnchor: constraint.topAnchor, pAnchors: pAnchors);
    });

    // AutoSize calculations
    for (double autoSizeCount = 1; autoSizeCount > 0 && autoSizeCount < 10000000;) {
      pComponentData.forEach((componentId, component) {
        //Todo LayoutData needs Visible - if(component.isVisible)
        if (true) {
          FormLayoutConstraints constraint = pComponentConstraints[componentId]!;
          Size preferredSize = component.preferredSize!;
          FLCalculateAnchorsUtil.calculateAutoSize(
              leftTopAnchor: constraint.topAnchor,
              rightBottomAnchor: constraint.bottomAnchor,
              preferredSize: preferredSize.height,
              autoSizeCount: autoSizeCount,
              pAnchors: pAnchors);
          FLCalculateAnchorsUtil.calculateAutoSize(
              leftTopAnchor: constraint.leftAnchor,
              rightBottomAnchor: constraint.rightAnchor,
              preferredSize: preferredSize.height,
              autoSizeCount: autoSizeCount,
              pAnchors: pAnchors);
        }
      });

      autoSizeCount = 10000000;

      pComponentData.forEach((componentId, component) {
        FormLayoutConstraints constraint = pComponentConstraints[componentId]!;

        double count;
        count = FLCalculateAnchorsUtil.finishAutoSizeCalculation(
            leftTopAnchor: constraint.leftAnchor, rightBottomAnchor: constraint.rightAnchor, pAnchors: pAnchors);
        if (count > 0 && count < autoSizeCount) {
          autoSizeCount = count;
        }
        count = FLCalculateAnchorsUtil.finishAutoSizeCalculation(
            leftTopAnchor: constraint.rightAnchor, rightBottomAnchor: constraint.leftAnchor, pAnchors: pAnchors);
        if (count > 0 && count < autoSizeCount) {
          autoSizeCount = count;
        }
        count = FLCalculateAnchorsUtil.finishAutoSizeCalculation(
            leftTopAnchor: constraint.topAnchor, rightBottomAnchor: constraint.bottomAnchor, pAnchors: pAnchors);
        if (count > 0 && count < autoSizeCount) {
          autoSizeCount = count;
        }
        count = FLCalculateAnchorsUtil.finishAutoSizeCalculation(
            leftTopAnchor: constraint.bottomAnchor, rightBottomAnchor: constraint.topAnchor, pAnchors: pAnchors);
        if (count > 0 && count < autoSizeCount) {
          autoSizeCount = count;
        }
      });
    }

    double leftWidth = 0;
    double rightWidth = 0;
    double topHeight = 0;
    double bottomHeight = 0;

    // Calculate preferredSize
    pComponentData.forEach((componentId, component) {
      FormLayoutConstraints constraint = pComponentConstraints[componentId]!;

      Size preferredComponentSize = component.preferredSize!;
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
    });

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

  void calculateTargetDependentAnchors(
      {required FormLayoutSize pMinPrefSize,
      required HashMap<String, FormLayoutAnchor> pAnchors,
      required HorizontalAlignment pHorizontalAlignment,
      required VerticalAlignment pVerticalAlignment,
      required FormLayoutUsedBorder pUsedBorder,
      required Margins pMargins,
      required HashMap<String, LayoutData> pComponentData,
      required HashMap<String, FormLayoutConstraints> pComponentConstraints,
      LayoutPosition? pGivenSize}) {
    /// ToDo SetSizes from server
    Size maxLayoutSize = const Size(100000000, 100000000);
    Size minLayoutSize = const Size(50, 50);

    /// Available Size, set to setSize from parent by default
    LayoutPosition calcSize = pGivenSize ?? LayoutPosition(width: 0, height: 0, top: 0, left: 0, isComponentSize: true);

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
    if (pHorizontalAlignment == HorizontalAlignment.stretch ||
        (pUsedBorder.leftBorderUsed && pUsedBorder.rightBorderUsed)) {
      if (minLayoutSize.width > calcSize.width) {
        lba.position = 0;
        rba.position = minLayoutSize.width;
      } else if (maxLayoutSize.width < calcSize.width) {
        switch (pHorizontalAlignment) {
          case HorizontalAlignment.left:
            lba.position = 0;
            break;
          case HorizontalAlignment.right:
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
          case HorizontalAlignment.left:
            lba.position = 0;
            break;
          case HorizontalAlignment.right:
            lba.position = calcSize.width - pMinPrefSize.preferredWidth;
            break;
          default:
            lba.position = (calcSize.width - pMinPrefSize.preferredWidth) / 2;
        }
        rba.position = lba.position + pMinPrefSize.preferredWidth;
      }
    }

    // Vertical Alignment
    if (pVerticalAlignment == VerticalAlignment.stretch ||
        (pUsedBorder.bottomBorderUsed && pUsedBorder.topBorderUsed)) {
      if (minLayoutSize.height > calcSize.height) {
        tba.position = 0;
        bba.position = minLayoutSize.height;
      } else if (maxLayoutSize.height < calcSize.height) {
        switch (pVerticalAlignment) {
          case VerticalAlignment.top:
            tba.position = 0;
            break;
          case VerticalAlignment.bottom:
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
          case VerticalAlignment.top:
            tba.position = 0;
            break;
          case VerticalAlignment.bottom:
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

    pComponentData.forEach((componentId, component) {
      ///ToDo Component Visible here
      if (true) {
        FormLayoutConstraints constraints = pComponentConstraints[componentId]!;
        Size preferredComponentSize = component.preferredSize!;

        FLCalculateDependentUtil.calculateRelativeAnchor(
            leftTopAnchor: constraints.leftAnchor,
            rightBottomAnchor: constraints.rightAnchor,
            preferredSize: preferredComponentSize.width);
        FLCalculateDependentUtil.calculateRelativeAnchor(
            leftTopAnchor: constraints.topAnchor,
            rightBottomAnchor: constraints.bottomAnchor,
            preferredSize: preferredComponentSize.height);
      }
    });
  }

  void buildComponents(
      {required HashMap<String, FormLayoutAnchor> pAnchors,
      required HashMap<String, FormLayoutConstraints> pComponentConstraints,
      required Margins pMargins}) {
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

    HashMap<String, LayoutPosition> sizeMap = HashMap();

    pComponentConstraints.forEach((componentId, constraint) {
      double left = constraint.leftAnchor.getAbsolutePosition() -
          marginConstraints.leftAnchor.getAbsolutePosition() +
          pMargins.marginLeft;
      double top = constraint.topAnchor.getAbsolutePosition() -
          marginConstraints.topAnchor.getAbsolutePosition() +
          pMargins.marginTop;
      double width = constraint.rightAnchor.getAbsolutePosition() - constraint.leftAnchor.getAbsolutePosition();
      double height = constraint.bottomAnchor.getAbsolutePosition() - constraint.topAnchor.getAbsolutePosition();

      LayoutPosition layoutPosition =
          LayoutPosition(width: width, height: height, isComponentSize: true, left: left, top: top);
      sizeMap[componentId] = layoutPosition;
      log("id: $componentId, height: $height, width: $width");
    });

    double height = borderConstraints.bottomAnchor.position - borderConstraints.topAnchor.position;
    double width = borderConstraints.rightAnchor.position - borderConstraints.leftAnchor.position;
    double left = marginConstraints.leftAnchor.getAbsolutePosition();
    double top = marginConstraints.topAnchor.getAbsolutePosition();

    log("height: $height, width: $width");
  }

  @override
  ILayout clone() {
    // TODO: implement clone
    throw UnimplementedError();
  }

  @override
  // TODO: implement listChildsToRedraw
  List<LayoutData> get listChildsToRedraw => throw UnimplementedError();
}
