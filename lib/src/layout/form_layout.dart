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

import 'dart:collection';
import 'dart:core';
import 'dart:math';

import 'package:flutter/widgets.dart';

import '../flutter_ui.dart';
import '../model/layout/alignments.dart';
import '../model/layout/form_layout/form_layout_anchor.dart';
import '../model/layout/form_layout/form_layout_constraints.dart';
import '../model/layout/form_layout/form_layout_size.dart';
import '../model/layout/form_layout/form_layout_used_border.dart';
import '../model/layout/gaps.dart';
import '../model/layout/layout_data.dart';
import '../model/layout/layout_position.dart';
import '../model/layout/margins.dart';
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

  /// The modifier with which to scale the layout.
  final double scaling;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FormLayout({required this.layoutData, required this.layoutString, required this.scaling})
      : splitLayoutString = layoutString.split(",") {
    margins = Margins.fromList(marginList: splitLayoutString.sublist(1, 5), scaling: scaling);
    gaps = Gaps.createFromList(gapsList: splitLayoutString.sublist(5, 7), scaling: scaling);
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
    return FormLayout(layoutData: layoutData, layoutString: layoutString, scaling: scaling);
  }

  @override
  void calculateLayout(LayoutData pParent, List<LayoutData> pChildren) {
    // Component constraints

    HashMap<String, FormLayoutConstraints> componentConstraints;
    // The layout call started before or after a specific set of data has been changed.
    try {
      componentConstraints = _getComponentConstraints(pChildren, anchors);
    } catch (error, stacktrace) {
      FlutterUI.logUI.w(
        "FormLayout of {${pParent.id}} crashed while getting the component constraints.",
        error,
        stacktrace,
      );
      return;
    }

    FormLayoutUsedBorder usedBorder = FormLayoutUsedBorder();
    FormLayoutSize formLayoutSize = FormLayoutSize();

    _calculateAnchors(
        pAnchors: anchors,
        pComponentData: pChildren,
        pComponentConstraints: componentConstraints,
        pUsedBorder: usedBorder,
        pPreferredMinimumSize: formLayoutSize,
        pGaps: gaps);

    // Size set by Parent
    Size calcSize = _getSize(pParent, formLayoutSize);

    _calculateTargetDependentAnchors(
      pMinPrefSize: formLayoutSize,
      pAnchors: anchors,
      pHorizontalAlignment: horizontalAlignment,
      pVerticalAlignment: verticalAlignment,
      pUsedBorder: usedBorder,
      pMargins: margins,
      pComponentData: pChildren,
      pComponentConstraints: componentConstraints,
      pGivenSize: calcSize,
      pParent: pParent,
    );

    return _buildComponents(
        pAnchors: anchors,
        pComponentConstraints: componentConstraints,
        pMargins: margins,
        id: pParent.id,
        pChildrenData: pChildren,
        pParent: pParent,
        pMinPrefSize: formLayoutSize);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Size _getSize(LayoutData pParent, FormLayoutSize pMinimumSize) {
    double dimWidth = pMinimumSize.preferredWidth;
    double dimHeight = pMinimumSize.preferredHeight;

    if (pParent.hasPosition) {
      if (pParent.layoutPosition!.isComponentSize) {
        dimWidth = pParent.layoutPosition!.width;
        dimHeight = pParent.layoutPosition!.height;
      } else {
        dimWidth = max(dimWidth, pParent.layoutPosition!.width);
        dimHeight = max(dimHeight, pParent.layoutPosition!.height);
      }
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
    // Clears the auto size
    clearAutoSize(pAnchors: pAnchors);

    // Part of clearing the auto size -> Visible component anchors are used.
    pComponentConstraints.forEach((key, value) {
      value.topAnchor.used = true;
      value.leftAnchor.used = true;
      value.bottomAnchor.used = true;
      value.rightAnchor.used = true;
    });

    // Init autoSize
    initAutoSize(pAnchors);

    // Init autoSize Anchors
    for (var component in pComponentData) {
      FormLayoutConstraints constraint = pComponentConstraints[component.id]!;

      initAutoSizeRelative(pStartAnchor: constraint.leftAnchor, pEndAnchor: constraint.rightAnchor, pAnchors: pAnchors);
      initAutoSizeRelative(pStartAnchor: constraint.rightAnchor, pEndAnchor: constraint.leftAnchor, pAnchors: pAnchors);
      initAutoSizeRelative(pStartAnchor: constraint.topAnchor, pEndAnchor: constraint.bottomAnchor, pAnchors: pAnchors);
      initAutoSizeRelative(pStartAnchor: constraint.bottomAnchor, pEndAnchor: constraint.topAnchor, pAnchors: pAnchors);
    }

    // AutoSize calculations
    for (double autoSizeCount = 1; autoSizeCount > 0 && autoSizeCount < 10000000;) {
      for (var component in pComponentData) {
        FormLayoutConstraints constraint = pComponentConstraints[component.id]!;
        Size preferredSize = component.bestSize;
        calculateAutoSize(
            pLeftTopAnchor: constraint.topAnchor,
            pRightBottomAnchor: constraint.bottomAnchor,
            pPreferredSize: preferredSize.height,
            pAutoSizeCount: autoSizeCount,
            pAnchors: pAnchors);
        calculateAutoSize(
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
        count = finishAutoSizeCalculation(
            leftTopAnchor: constraint.leftAnchor, rightBottomAnchor: constraint.rightAnchor, pAnchors: pAnchors);
        if (count > 0 && count < autoSizeCount) {
          autoSizeCount = count;
        }
        count = finishAutoSizeCalculation(
            leftTopAnchor: constraint.rightAnchor, rightBottomAnchor: constraint.leftAnchor, pAnchors: pAnchors);
        if (count > 0 && count < autoSizeCount) {
          autoSizeCount = count;
        }
        count = finishAutoSizeCalculation(
            leftTopAnchor: constraint.topAnchor, rightBottomAnchor: constraint.bottomAnchor, pAnchors: pAnchors);
        if (count > 0 && count < autoSizeCount) {
          autoSizeCount = count;
        }
        count = finishAutoSizeCalculation(
            leftTopAnchor: constraint.bottomAnchor, rightBottomAnchor: constraint.topAnchor, pAnchors: pAnchors);
        if (count > 0 && count < autoSizeCount) {
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
          bottomHeight = h;
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
            pPreferredMinimumSize.minimumWidth = w;
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
      FormLayoutAnchor rma = pAnchors['rm']!;
      double w = leftWidth - rma.position;
      if (w > pPreferredMinimumSize.preferredWidth) {
        pPreferredMinimumSize.preferredWidth = w;
      }
      if (w > pPreferredMinimumSize.minimumWidth) {
        pPreferredMinimumSize.minimumWidth = w;
      }
    } else {
      FormLayoutAnchor lma = pAnchors['lm']!;
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
      FormLayoutAnchor bma = pAnchors['bm']!;
      double h = topHeight - bma.position;
      if (h > pPreferredMinimumSize.preferredHeight) {
        pPreferredMinimumSize.preferredHeight = h;
      }
      if (h > pPreferredMinimumSize.minimumHeight) {
        pPreferredMinimumSize.minimumHeight = h;
      }
    } else {
      FormLayoutAnchor tma = pAnchors['tm']!;
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
      Size? pGivenSize,
      required LayoutData pParent}) {
    /// ToDo SetSizes from server
    Size maxLayoutSize = pParent.maxSize ?? const Size.square(double.maxFinite);
    Size minLayoutSize = pParent.minSize ?? const Size.square(0);

    /// Available Size, set to setSize from parent by default
    Size calcSize = pGivenSize ?? Size(pMinPrefSize.preferredWidth, pMinPrefSize.preferredHeight);

    FormLayoutAnchor lba = pAnchors['l']!;
    FormLayoutAnchor rba = pAnchors['r']!;
    FormLayoutAnchor bba = pAnchors['b']!;
    FormLayoutAnchor tba = pAnchors['t']!;

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
        rba.position = lba.position + maxLayoutSize.width;
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
      calculateRelativeAnchor(
          leftTopAnchor: constraints.leftAnchor,
          rightBottomAnchor: constraints.rightAnchor,
          preferredSize: preferredComponentSize.width);
      calculateRelativeAnchor(
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
    // FormLayoutAnchor lba = pAnchors['l']!;
    // FormLayoutAnchor rba = pAnchors['r']!;
    // FormLayoutAnchor tba = pAnchors['t']!;
    // FormLayoutAnchor bba = pAnchors['b']!;

    FormLayoutAnchor tma = pAnchors['tm']!;
    FormLayoutAnchor bma = pAnchors['bm']!;
    FormLayoutAnchor lma = pAnchors['lm']!;
    FormLayoutAnchor rma = pAnchors['rm']!;

    /// Used for components
    FormLayoutConstraints marginConstraints =
        FormLayoutConstraints(bottomAnchor: bma, leftAnchor: lma, rightAnchor: rma, topAnchor: tma);

    /// Used for layoutSize
    // FormLayoutConstraints borderConstraints =
    //     FormLayoutConstraints(bottomAnchor: bba, leftAnchor: lba, rightAnchor: rba, topAnchor: tba);

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

      layoutData.layoutPosition =
          LayoutPosition(width: width, height: height, isComponentSize: true, left: left, top: top);
    });

    Size preferred = Size(pMinPrefSize.preferredWidth, pMinPrefSize.preferredHeight);

    pParent.calculatedSize = preferred;
  }

  /// Parses all anchors from layoutData and establishes relatedAnchors
  HashMap<String, FormLayoutAnchor> _getAnchors(String layoutData) {
    HashMap<String, FormLayoutAnchor> anchors = HashMap();

    // Parse layoutData to get Anchors
    final List<String> splitAnchors = layoutData.split(";");
    for (var stringAnchor in splitAnchors) {
      String name = stringAnchor.substring(0, stringAnchor.indexOf(","));
      anchors[name] = FormLayoutAnchor.fromAnchorData(pAnchorData: stringAnchor, scaling: scaling);
    }

    // Establish relatedAnchors
    anchors.forEach((anchorName, anchor) {
      anchor.relatedAnchor = anchors[anchor.relatedAnchorName];
    });
    return anchors;
  }

  /// Creates [FormLayoutConstraints] for every [LayoutData] (child)
  HashMap<String, FormLayoutConstraints> _getComponentConstraints(
      List<LayoutData> components, HashMap<String, FormLayoutAnchor> anchors) {
    HashMap<String, FormLayoutConstraints> componentConstraints = HashMap();

    for (var value in components) {
      List<String> anchorNames = value.constraints!.split(";");
      try {
        // Get Anchors
        FormLayoutAnchor topAnchor = anchors[anchorNames[0]]!;
        FormLayoutAnchor leftAnchor = anchors[anchorNames[1]]!;
        FormLayoutAnchor bottomAnchor = anchors[anchorNames[2]]!;
        FormLayoutAnchor rightAnchor = anchors[anchorNames[3]]!;
        // Build Constraint
        FormLayoutConstraints constraint = FormLayoutConstraints(
            bottomAnchor: bottomAnchor, leftAnchor: leftAnchor, rightAnchor: rightAnchor, topAnchor: topAnchor);
        componentConstraints[value.id] = constraint;
      } catch (error, stacktrace) {
        FlutterUI.logUI.e("Parent id: ${value.parentId!}");
        FlutterUI.logUI.e("Child id: ${value.id}");
        var keys = anchors.keys.toList()..sort();
        anchorNames.sort();
        FlutterUI.logUI.e(keys.toString());
        FlutterUI.logUI.e(anchorNames.toString());
        FlutterUI.logUI.e(anchorNames.where((anchorName) => !keys.contains(anchorName)).toString(), error, stacktrace);
        rethrow;
      }
    }
    return componentConstraints;
  }

  /// Calculates the preferred size of relative anchors.
  void calculateRelativeAnchor(
      {required FormLayoutAnchor leftTopAnchor,
      required FormLayoutAnchor rightBottomAnchor,
      required double preferredSize}) {
    if (leftTopAnchor.relative) {
      FormLayoutAnchor? rightBottom = rightBottomAnchor.getRelativeAnchor();
      if (rightBottom != leftTopAnchor) {
        double pref = rightBottom.getAbsolutePosition() - rightBottomAnchor.getAbsolutePosition() + preferredSize;
        double size = 0;
        if (rightBottom.relatedAnchor != null && leftTopAnchor.relatedAnchor != null) {
          size = rightBottom.relatedAnchor!.getAbsolutePosition() - leftTopAnchor.relatedAnchor!.getAbsolutePosition();
        }
        double pos = pref - size;

        if (pos < 0) {
          pos /= 2;
        } else {
          pos -= pos / 2;
        }

        if (rightBottom.firstCalculation || pos > rightBottom.position) {
          rightBottom.firstCalculation = false;
          rightBottom.position = pos;
        }
        pos = pref - size - pos;
        if (leftTopAnchor.firstCalculation || pos > leftTopAnchor.position) {
          leftTopAnchor.firstCalculation = false;
          leftTopAnchor.position = -pos;
        }
      }
    }
  }

  /// Gets all non-calculated auto size anchors between start and end anchor
  List<FormLayoutAnchor> getAutoSizeAnchorsBetween(
      {required FormLayoutAnchor pStartAnchor,
      required FormLayoutAnchor pEndAnchor,
      required HashMap<String, FormLayoutAnchor> pAnchors}) {
    List<FormLayoutAnchor> autoSizeAnchors = [];
    FormLayoutAnchor? startAnchor = pStartAnchor;
    while (startAnchor != null && startAnchor != pEndAnchor) {
      if (startAnchor.autoSize && !startAnchor.autoSizeCalculated) {
        autoSizeAnchors.add(startAnchor);
      }
      startAnchor = startAnchor.relatedAnchor;
    }

    // If the anchors are not dependent on each other return an empty array!
    if (startAnchor == null) {
      return [];
    }
    return autoSizeAnchors;
  }

  /// Init component auto size position of anchor.
  void initAutoSizeRelative(
      {required FormLayoutAnchor pStartAnchor,
      required FormLayoutAnchor pEndAnchor,
      required HashMap<String, FormLayoutAnchor> pAnchors}) {
    List<FormLayoutAnchor> autoSizeAnchors =
        getAutoSizeAnchorsBetween(pStartAnchor: pStartAnchor, pEndAnchor: pEndAnchor, pAnchors: pAnchors);
    for (FormLayoutAnchor anchor in autoSizeAnchors) {
      anchor.relative = false;
    }
  }

  /// Calculates the preferred size of component auto size anchors.
  void calculateAutoSize(
      {required FormLayoutAnchor pLeftTopAnchor,
      required FormLayoutAnchor pRightBottomAnchor,
      required double pPreferredSize,
      required double pAutoSizeCount,
      required HashMap<String, FormLayoutAnchor> pAnchors}) {
    List<FormLayoutAnchor> autoSizeAnchors =
        getAutoSizeAnchorsBetween(pStartAnchor: pLeftTopAnchor, pEndAnchor: pRightBottomAnchor, pAnchors: pAnchors);

    if (autoSizeAnchors.length == pAutoSizeCount) {
      double fixedSize = pRightBottomAnchor.getAbsolutePosition() - pLeftTopAnchor.getAbsolutePosition();
      for (FormLayoutAnchor anchor in autoSizeAnchors) {
        fixedSize += anchor.position;
      }
      double diffSize = (pPreferredSize - fixedSize + pAutoSizeCount - 1) / pAutoSizeCount;
      for (FormLayoutAnchor anchor in autoSizeAnchors) {
        if (diffSize > -anchor.position) {
          anchor.position = -diffSize;
        }
        anchor.firstCalculation = false;
      }
    }

    autoSizeAnchors =
        getAutoSizeAnchorsBetween(pStartAnchor: pRightBottomAnchor, pEndAnchor: pLeftTopAnchor, pAnchors: pAnchors);
    if (autoSizeAnchors.length == pAutoSizeCount) {
      double fixedSize = pRightBottomAnchor.getAbsolutePosition() - pLeftTopAnchor.getAbsolutePosition();
      for (FormLayoutAnchor anchor in autoSizeAnchors) {
        fixedSize -= anchor.position;
      }
      double diffSize = (pPreferredSize - fixedSize + pAutoSizeCount - 1) / pAutoSizeCount;
      for (FormLayoutAnchor anchor in autoSizeAnchors) {
        if (diffSize > anchor.position) {
          anchor.position = diffSize;
        }
        anchor.firstCalculation = false;
      }
    }
  }

  /// Marks all touched AutoSize anchors as calculated
  double finishAutoSizeCalculation(
      {required FormLayoutAnchor leftTopAnchor,
      required FormLayoutAnchor rightBottomAnchor,
      required HashMap<String, FormLayoutAnchor> pAnchors}) {
    List<FormLayoutAnchor> autoSizeAnchors =
        getAutoSizeAnchorsBetween(pStartAnchor: leftTopAnchor, pEndAnchor: rightBottomAnchor, pAnchors: pAnchors);
    double counter = 0;
    for (FormLayoutAnchor anchor in autoSizeAnchors) {
      if (!anchor.firstCalculation) {
        anchor.autoSizeCalculated = true;
        counter++;
      }
    }
    return autoSizeAnchors.length - counter;
  }

  /// Clears auto size position of anchors
  void clearAutoSize({required HashMap<String, FormLayoutAnchor> pAnchors}) {
    pAnchors.forEach((anchorName, anchor) {
      anchor.relative = anchor.autoSize;
      anchor.autoSizeCalculated = false;
      anchor.firstCalculation = true;
      anchor.used = false;

      if (anchor.autoSize) {
        anchor.position = 0;
      }
    });
  }

  void initAutoSize(HashMap<String, FormLayoutAnchor> pAnchors) {
    // Init autoSize Anchor position
    pAnchors.forEach((anchorName, anchor) {
      // Check if two autoSize anchors are side by side

      FormLayoutAnchor? relatedAnchor = anchor.relatedAnchor;
      if (anchor.relatedAnchor != null) {
        if (!anchor.used && relatedAnchor!.used && !relatedAnchor.name.contains("m")) {
          anchor.used = true;
        }

        if (relatedAnchor!.autoSize &&
            !anchor.autoSize &&
            relatedAnchor.relatedAnchor != null &&
            !relatedAnchor.relatedAnchor!.autoSize) {
          relatedAnchor.position = relatedAnchor.used ? -relatedAnchor.relatedAnchor!.position : -anchor.position;
        }
      }
    });
  }
}
