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
import '../util/jvx_logger.dart';
import 'i_layout.dart';

class FormLayout extends ILayout {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The original layout string
  final String layoutString;

  /// The original layout data string
  final String layoutData;

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

  FormLayout({required this.layoutString,
    required this.scaling,
    required this.layoutData}
  ) {
    List<String> layoutDef = layoutString.split(",");

    margins = ILayout.marginsFromList(marginList: layoutDef.sublist(1, 5), scaling: scaling);
    gaps = Gaps.createFromList(gapsList: layoutDef.sublist(5, 7), scaling: scaling);
    alignment = layoutDef.sublist(7, 9);
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
  void calculateLayout(LayoutData parent, List<LayoutData> children) {
    // Component constraints

    HashMap<String, FormLayoutConstraints> componentConstraints;
    // The layout call started before or after a specific set of data has been changed.
    try {
      componentConstraints = _getComponentConstraints(children, anchors);
    } catch (error, stacktrace) {
      if (FlutterUI.logLayout.cl(Lvl.w)) {
        FlutterUI.logLayout.w(
          "FormLayout of {${parent.id}} crashed while getting the component constraints.",
          error: error,
          stackTrace: stacktrace,
        );
      }

      return;
    }

    FormLayoutUsedBorder usedBorder = FormLayoutUsedBorder();
    FormLayoutSize formLayoutSize = FormLayoutSize();

    _calculateAnchors(
        anchors: anchors,
        componentData: children,
        componentConstraints: componentConstraints,
        usedBorder: usedBorder,
        preferredMinimumSize: formLayoutSize,
        gaps: gaps);

    _calculateTargetDependentAnchors(
      minPrefSize: formLayoutSize,
      anchors: anchors,
      horizontalAlignment: horizontalAlignment,
      verticalAlignment: verticalAlignment,
      usedBorder: usedBorder,
      componentData: children,
      componentConstraints: componentConstraints,
      givenSize: _getSize(parent, formLayoutSize),
      parent: parent,
    );

    return _buildComponents(
        anchors: anchors,
        componentConstraints: componentConstraints,
        id: parent.id,
        childrenData: children,
        parent: parent,
        minPrefSize: formLayoutSize);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Size _getSize(LayoutData parent, FormLayoutSize minimumSize) {
    double dimWidth = minimumSize.preferredWidth;
    double dimHeight = minimumSize.preferredHeight;

    if (parent.hasPosition) {
      dimWidth = parent.layoutPosition!.width;
      dimHeight = parent.layoutPosition!.height;
    }

    dimWidth -= parent.insets.horizontal;
    dimHeight -= parent.insets.vertical;

    return Size(dimWidth, dimHeight);
  }

  void _calculateAnchors(
      {required HashMap<String, FormLayoutAnchor> anchors,
      required List<LayoutData> componentData,
      required HashMap<String, FormLayoutConstraints> componentConstraints,
      required FormLayoutUsedBorder usedBorder,
      required FormLayoutSize preferredMinimumSize,
      required Gaps gaps}) {
    // Clears the auto size
    _clearAutoSize(anchors: anchors);

    // Part of clearing the auto size -> Visible component anchors are used.
    componentConstraints.forEach((key, value) {
      value.topAnchor.used = true;
      value.leftAnchor.used = true;
      value.bottomAnchor.used = true;
      value.rightAnchor.used = true;
    });

    // Init autoSize
    _initAutoSize(anchors);

    // Init autoSize Anchors
    for (var component in componentData) {
      FormLayoutConstraints constraint = componentConstraints[component.id]!;

      _initAutoSizeRelative(startAnchor: constraint.leftAnchor, endAnchor: constraint.rightAnchor, anchors: anchors);
      _initAutoSizeRelative(startAnchor: constraint.rightAnchor, endAnchor: constraint.leftAnchor, anchors: anchors);
      _initAutoSizeRelative(startAnchor: constraint.topAnchor, endAnchor: constraint.bottomAnchor, anchors: anchors);
      _initAutoSizeRelative(startAnchor: constraint.bottomAnchor, endAnchor: constraint.topAnchor, anchors: anchors);
    }

    // AutoSize calculations
    for (double autoSizeCount = 1; autoSizeCount > 0 && autoSizeCount < 10000000;) {
      for (var component in componentData) {
        FormLayoutConstraints constraint = componentConstraints[component.id]!;
        Size preferredSize = component.bestSize;

        _calculateAutoSize(
            leftTopAnchor: constraint.topAnchor,
            rightBottomAnchor: constraint.bottomAnchor,
            preferredSize: preferredSize.height,
            autoSizeCount: autoSizeCount,
            anchors: anchors);
        _calculateAutoSize(
            leftTopAnchor: constraint.leftAnchor,
            rightBottomAnchor: constraint.rightAnchor,
            preferredSize: preferredSize.width,
            autoSizeCount: autoSizeCount,
            anchors: anchors);
      }
      autoSizeCount = 10000000;

      for (var component in componentData) {
        FormLayoutConstraints constraint = componentConstraints[component.id]!;

        double count;
        count = _finishAutoSizeCalculation(
            leftTopAnchor: constraint.leftAnchor, rightBottomAnchor: constraint.rightAnchor, anchors: anchors);
        if (count > 0 && count < autoSizeCount) {
          autoSizeCount = count;
        }
        count = _finishAutoSizeCalculation(
            leftTopAnchor: constraint.rightAnchor, rightBottomAnchor: constraint.leftAnchor, anchors: anchors);
        if (count > 0 && count < autoSizeCount) {
          autoSizeCount = count;
        }
        count = _finishAutoSizeCalculation(
            leftTopAnchor: constraint.topAnchor, rightBottomAnchor: constraint.bottomAnchor, anchors: anchors);
        if (count > 0 && count < autoSizeCount) {
          autoSizeCount = count;
        }
        count = _finishAutoSizeCalculation(
            leftTopAnchor: constraint.bottomAnchor, rightBottomAnchor: constraint.topAnchor, anchors: anchors);
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
    for (var component in componentData) {
      FormLayoutConstraints constraint = componentConstraints[component.id]!;

      Size preferredComponentSize = component.bestSize;
      Size minimumComponentSize = component.minSize ?? const Size(0, 0);

      if (constraint.rightAnchor.getBorderAnchor().name == "l") {
        double w = constraint.rightAnchor.getAbsolutePosition();
        if (w > leftWidth) {
          leftWidth = w;
        }
        usedBorder.leftBorderUsed = true;
      }
      if (constraint.leftAnchor.getBorderAnchor().name == "r") {
        double w = -constraint.leftAnchor.getAbsolutePosition();
        if (w > rightWidth) {
          rightWidth = w;
        }
        usedBorder.rightBorderUsed = true;
      }
      if (constraint.bottomAnchor.getBorderAnchor().name == "t") {
        double h = constraint.bottomAnchor.getAbsolutePosition();
        if (h > topHeight) {
          topHeight = h;
        }
        usedBorder.topBorderUsed = true;
      }
      if (constraint.topAnchor.getBorderAnchor().name == "b") {
        double h = -constraint.topAnchor.getAbsolutePosition();
        if (h > bottomHeight) {
          bottomHeight = h;
        }
        usedBorder.bottomBorderUsed = true;
      }

      if (constraint.leftAnchor.getBorderAnchor().name == "l" && constraint.rightAnchor.getBorderAnchor().name == "r") {
        if (!constraint.leftAnchor.autoSize || !constraint.rightAnchor.autoSize) {
          double w = constraint.leftAnchor.getAbsolutePosition() -
              constraint.rightAnchor.getAbsolutePosition() +
              preferredComponentSize.width;
          if (w > preferredMinimumSize.preferredWidth) {
            preferredMinimumSize.preferredWidth = w;
          }
          w = constraint.leftAnchor.getAbsolutePosition() -
              constraint.rightAnchor.getAbsolutePosition() +
              minimumComponentSize.width;
          if (w > preferredMinimumSize.minimumWidth) {
            preferredMinimumSize.minimumWidth = w;
          }
        }
        usedBorder.leftBorderUsed = true;
        usedBorder.rightBorderUsed = true;
      }
      if (constraint.topAnchor.getBorderAnchor().name == "t" && constraint.bottomAnchor.getBorderAnchor().name == "b") {
        if (!constraint.topAnchor.autoSize || !constraint.bottomAnchor.autoSize) {
          double h = constraint.topAnchor.getAbsolutePosition() -
              constraint.bottomAnchor.getAbsolutePosition() +
              preferredComponentSize.height;
          if (h > preferredMinimumSize.preferredHeight) {
            preferredMinimumSize.preferredHeight = h;
          }
          h = constraint.topAnchor.getAbsolutePosition() -
              constraint.bottomAnchor.getAbsolutePosition() +
              minimumComponentSize.height;
          if (h > preferredMinimumSize.minimumHeight) {
            preferredMinimumSize.minimumHeight = h;
          }
        }
        usedBorder.topBorderUsed = true;
        usedBorder.bottomBorderUsed = true;
      }
    }

    /// Preferred width
    if (leftWidth != 0 && rightWidth != 0) {
      double w = leftWidth + rightWidth + gaps.horizontalGap;
      if (w > preferredMinimumSize.preferredWidth) {
        preferredMinimumSize.preferredWidth = w;
      }
      if (w > preferredMinimumSize.minimumWidth) {
        preferredMinimumSize.minimumWidth = w;
      }
    } else if (leftWidth != 0) {
      FormLayoutAnchor rma = anchors["rm"]!;
      double w = leftWidth - rma.position;
      if (w > preferredMinimumSize.preferredWidth) {
        preferredMinimumSize.preferredWidth = w;
      }
      if (w > preferredMinimumSize.minimumWidth) {
        preferredMinimumSize.minimumWidth = w;
      }
    } else {
      FormLayoutAnchor lma = anchors["lm"]!;
      double w = rightWidth + lma.position;
      if (w > preferredMinimumSize.preferredWidth) {
        preferredMinimumSize.preferredWidth = w;
      }
      if (w > preferredMinimumSize.minimumWidth) {
        preferredMinimumSize.minimumWidth = w;
      }
    }

    /// Preferred height
    if (topHeight != 0 && bottomHeight != 0) {
      double h = topHeight + bottomHeight + gaps.verticalGap;
      if (h > preferredMinimumSize.preferredHeight) {
        preferredMinimumSize.preferredHeight = h;
      }
      if (h > preferredMinimumSize.minimumHeight) {
        preferredMinimumSize.minimumHeight = h;
      }
    } else if (topHeight != 0) {
      FormLayoutAnchor bma = anchors["bm"]!;
      double h = topHeight - bma.position;
      if (h > preferredMinimumSize.preferredHeight) {
        preferredMinimumSize.preferredHeight = h;
      }
      if (h > preferredMinimumSize.minimumHeight) {
        preferredMinimumSize.minimumHeight = h;
      }
    } else {
      FormLayoutAnchor tma = anchors["tm"]!;
      double h = bottomHeight + tma.position;
      if (h > preferredMinimumSize.preferredHeight) {
        preferredMinimumSize.preferredHeight = h;
      }
      if (h > preferredMinimumSize.minimumHeight) {
        preferredMinimumSize.minimumHeight;
      }
    }
  }

  void _calculateTargetDependentAnchors({
    required FormLayoutSize minPrefSize,
    required HashMap<String, FormLayoutAnchor> anchors,
    required HorizontalAlignment horizontalAlignment,
    required VerticalAlignment verticalAlignment,
    required FormLayoutUsedBorder usedBorder,
    required List<LayoutData> componentData,
    required HashMap<String, FormLayoutConstraints> componentConstraints,
    Size? givenSize,
    required LayoutData parent}
  ) {
    Size maxLayoutSize = parent.maxSize ?? const Size.square(double.maxFinite);
    Size minLayoutSize = parent.minSize ?? const Size.square(0);

    /// Available Size, set to setSize from parent by default
    Size calcSize = givenSize ?? Size(minPrefSize.preferredWidth, minPrefSize.preferredHeight);

    FormLayoutAnchor lba = anchors["l"]!;
    FormLayoutAnchor rba = anchors["r"]!;
    FormLayoutAnchor bba = anchors["b"]!;
    FormLayoutAnchor tba = anchors["t"]!;

    // Horizontal Alignment
    if (horizontalAlignment == HorizontalAlignment.STRETCH ||
        (usedBorder.leftBorderUsed && usedBorder.rightBorderUsed)) {
      if (minLayoutSize.width > calcSize.width) {
        lba.position = 0;
        rba.position = minLayoutSize.width;
      } else if (maxLayoutSize.width < calcSize.width) {
        switch (horizontalAlignment) {
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
      if (minPrefSize.preferredWidth > calcSize.width) {
        lba.position = 0;
      } else {
        switch (horizontalAlignment) {
          case HorizontalAlignment.LEFT:
            lba.position = 0;
            break;
          case HorizontalAlignment.RIGHT:
            lba.position = calcSize.width - minPrefSize.preferredWidth;
            break;
          default:
            lba.position = (calcSize.width - minPrefSize.preferredWidth) / 2;
        }
        rba.position = lba.position + minPrefSize.preferredWidth;
      }
    }

    // Vertical Alignment
    if (verticalAlignment == VerticalAlignment.STRETCH ||
        (usedBorder.bottomBorderUsed && usedBorder.topBorderUsed)) {
      if (minLayoutSize.height > calcSize.height) {
        tba.position = 0;
        bba.position = minLayoutSize.height;
      } else if (maxLayoutSize.height < calcSize.height) {
        switch (verticalAlignment) {
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
      if (minPrefSize.preferredHeight > calcSize.height) {
        tba.position = 0;
      } else {
        switch (verticalAlignment) {
          case VerticalAlignment.TOP:
            tba.position = 0;
            break;
          case VerticalAlignment.BOTTOM:
            tba.position = calcSize.height - minPrefSize.preferredHeight;
            break;
          default:
            tba.position = (calcSize.height - minPrefSize.preferredHeight) / 2;
        }
        bba.position = tba.position + minPrefSize.preferredHeight;
      }
    }

    lba.position -= margins.left;
    rba.position -= margins.left;
    tba.position -= margins.top;
    bba.position -= margins.top;

    for (var component in componentData) {
      FormLayoutConstraints constraints = componentConstraints[component.id]!;
      Size preferredComponentSize = component.bestSize;
      _calculateRelativeAnchor(
          leftTopAnchor: constraints.leftAnchor,
          rightBottomAnchor: constraints.rightAnchor,
          preferredSize: preferredComponentSize.width);
      _calculateRelativeAnchor(
          leftTopAnchor: constraints.topAnchor,
          rightBottomAnchor: constraints.bottomAnchor,
          preferredSize: preferredComponentSize.height);
    }
  }

  void _buildComponents(
      {required HashMap<String, FormLayoutAnchor> anchors,
      required HashMap<String, FormLayoutConstraints> componentConstraints,
      required String id,
      required List<LayoutData> childrenData,
      required LayoutData parent,
      required FormLayoutSize minPrefSize}) {
    /// Get Border- and Margin Anchors for calculation
    // FormLayoutAnchor lba = anchors["l"]!;
    // FormLayoutAnchor rba = anchors["r"]!;
    // FormLayoutAnchor tba = anchors["t"]!;
    // FormLayoutAnchor bba = anchors["b"]!;

    FormLayoutAnchor tma = anchors["tm"]!;
    FormLayoutAnchor bma = anchors["bm"]!;
    FormLayoutAnchor lma = anchors["lm"]!;
    FormLayoutAnchor rma = anchors["rm"]!;

    /// Used for components
    FormLayoutConstraints marginConstraints =
        FormLayoutConstraints(bottomAnchor: bma, leftAnchor: lma, rightAnchor: rma, topAnchor: tma);

    /// Used for layoutSize
    // FormLayoutConstraints borderConstraints =
    //     FormLayoutConstraints(bottomAnchor: bba, leftAnchor: lba, rightAnchor: rba, topAnchor: tba);

    // This layout has additional margins to add.
    double additionalLeft = marginConstraints.leftAnchor.getAbsolutePosition();
    double additionalTop = marginConstraints.topAnchor.getAbsolutePosition();

    componentConstraints.forEach((componentId, constraint) {
      double left = constraint.leftAnchor.getAbsolutePosition() -
          marginConstraints.leftAnchor.getAbsolutePosition() +
          margins.left +
          additionalLeft;

      double top = constraint.topAnchor.getAbsolutePosition() -
          marginConstraints.topAnchor.getAbsolutePosition() +
          margins.top +
          additionalTop;

      double width = constraint.rightAnchor.getAbsolutePosition() - constraint.leftAnchor.getAbsolutePosition();
      double height = constraint.bottomAnchor.getAbsolutePosition() - constraint.topAnchor.getAbsolutePosition();

      LayoutData layoutData = childrenData.firstWhere((element) => element.id == componentId);

      layoutData.layoutPosition = LayoutPosition(width: width, height: height, left: left, top: top);
    });

    Size preferred = Size(minPrefSize.preferredWidth, minPrefSize.preferredHeight);

    parent.calculatedSize = preferred + Offset(parent.insets.horizontal, parent.insets.vertical);
  }

  /// Parses all anchors from layoutData and establishes relatedAnchors
  HashMap<String, FormLayoutAnchor> _getAnchors(String layoutData) {
    HashMap<String, FormLayoutAnchor> anchors = HashMap();

    // Parse layoutData to get Anchors
    final List<String> splitAnchors = layoutData.split(";");
    for (var stringAnchor in splitAnchors) {
      String name = stringAnchor.substring(0, stringAnchor.indexOf(","));
      anchors[name] = FormLayoutAnchor.fromAnchorData(anchorData: stringAnchor, scaling: scaling);
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
        if (FlutterUI.logLayout.cl(Lvl.e)) {
          FlutterUI.logLayout.e("Parent id: ${value.parentId!}");
          FlutterUI.logLayout.e("Child id: ${value.id}");

          var keys = anchors.keys.toList()..sort();
          anchorNames.sort();

          FlutterUI.logLayout.e(keys.toString());
          FlutterUI.logLayout.e(anchorNames.toString());
          FlutterUI.logLayout.e(anchorNames.where((anchorName) => !keys.contains(anchorName)).toString(),
              error: error, stackTrace: stacktrace);
        }

        rethrow;
      }
    }
    return componentConstraints;
  }

  /// Calculates the preferred size of relative anchors.
  void _calculateRelativeAnchor(
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
    } else if (rightBottomAnchor.relative) {
      FormLayoutAnchor leftTop = leftTopAnchor.getRelativeAnchor();
      if (leftTop != rightBottomAnchor) {
        double pref = leftTopAnchor.getAbsolutePosition() - leftTop.getAbsolutePosition() + preferredSize;
        double size = 0;
        if (rightBottomAnchor.relatedAnchor != null && leftTop.relatedAnchor != null) {
          size = rightBottomAnchor.relatedAnchor!.getAbsolutePosition() - leftTop.relatedAnchor!.getAbsolutePosition();
        }

        double pos = pref - size;

        if (pos < 0) {
          pos -= pos / 2;
        } else {
          pos /= 2;
        }
        if (leftTop.firstCalculation || pos < leftTop.position) {
          leftTop.firstCalculation = false;
          leftTop.position = pos;
        }
        pos = pref - size - pos;
        if (rightBottomAnchor.firstCalculation || pos > -rightBottomAnchor.position) {
          rightBottomAnchor.firstCalculation = false;
          rightBottomAnchor.position = -pos;
        }
      }
    }
  }

  /// Gets all non-calculated auto size anchors between start and end anchor
  List<FormLayoutAnchor> _getAutoSizeAnchorsBetween(
      {required FormLayoutAnchor startAnchor,
      required FormLayoutAnchor endAnchor,
      required HashMap<String, FormLayoutAnchor> anchors}) {
    List<FormLayoutAnchor> autoSizeAnchors = [];
    FormLayoutAnchor? startAnchor_ = startAnchor;

    while (startAnchor_ != null && startAnchor_ != endAnchor) {
      if (startAnchor_.autoSize && !startAnchor_.autoSizeCalculated) {
        autoSizeAnchors.add(startAnchor_);
      }
      startAnchor_ = startAnchor_.relatedAnchor;
    }

    // If the anchors are not dependent on each other return an empty array!
    if (startAnchor_ == null) {
      return [];
    }
    return autoSizeAnchors;
  }

  /// Init component auto size position of anchor.
  void _initAutoSizeRelative(
      {required FormLayoutAnchor startAnchor,
      required FormLayoutAnchor endAnchor,
      required HashMap<String, FormLayoutAnchor> anchors}) {
    List<FormLayoutAnchor> autoSizeAnchors =
        _getAutoSizeAnchorsBetween(startAnchor: startAnchor, endAnchor: endAnchor, anchors: anchors);
    for (FormLayoutAnchor anchor in autoSizeAnchors) {
      anchor.relative = false;
    }
  }

  /// Calculates the preferred size of component auto size anchors.
  void _calculateAutoSize(
      {required FormLayoutAnchor leftTopAnchor,
      required FormLayoutAnchor rightBottomAnchor,
      required double preferredSize,
      required double autoSizeCount,
      required HashMap<String, FormLayoutAnchor> anchors}) {
    List<FormLayoutAnchor> autoSizeAnchors =
        _getAutoSizeAnchorsBetween(startAnchor: leftTopAnchor, endAnchor: rightBottomAnchor, anchors: anchors);

    if (autoSizeAnchors.length == autoSizeCount) {
      double fixedSize = rightBottomAnchor.getAbsolutePosition() - leftTopAnchor.getAbsolutePosition();
      for (FormLayoutAnchor anchor in autoSizeAnchors) {
        fixedSize += anchor.position;
      }
      double diffSize = (preferredSize - fixedSize + autoSizeCount - 1) / autoSizeCount;
      for (FormLayoutAnchor anchor in autoSizeAnchors) {
        if (diffSize > -anchor.position) {
          anchor.position = -diffSize;
        }
        anchor.firstCalculation = false;
      }
    }

    autoSizeAnchors =
        _getAutoSizeAnchorsBetween(startAnchor: rightBottomAnchor, endAnchor: leftTopAnchor, anchors: anchors);

    if (autoSizeAnchors.length == autoSizeCount) {
      double fixedSize = rightBottomAnchor.getAbsolutePosition() - leftTopAnchor.getAbsolutePosition();
      for (FormLayoutAnchor anchor in autoSizeAnchors) {
        fixedSize -= anchor.position;
      }
      double diffSize = (preferredSize - fixedSize + autoSizeCount - 1) / autoSizeCount;
      for (FormLayoutAnchor anchor in autoSizeAnchors) {
        if (diffSize > anchor.position) {
          anchor.position = diffSize;
        }
        anchor.firstCalculation = false;
      }
    }
  }

  /// Marks all touched AutoSize anchors as calculated
  double _finishAutoSizeCalculation(
      {required FormLayoutAnchor leftTopAnchor,
      required FormLayoutAnchor rightBottomAnchor,
      required HashMap<String, FormLayoutAnchor> anchors}) {
    List<FormLayoutAnchor> autoSizeAnchors =
        _getAutoSizeAnchorsBetween(startAnchor: leftTopAnchor, endAnchor: rightBottomAnchor, anchors: anchors);
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
  void _clearAutoSize({required HashMap<String, FormLayoutAnchor> anchors}) {
    anchors.forEach((anchorName, anchor) {
      anchor.relative = anchor.autoSize;
      anchor.autoSizeCalculated = false;
      anchor.firstCalculation = true;
      anchor.used = false;

      if (anchor.autoSize) {
        anchor.position = 0;
      }
    });
  }

  void _initAutoSize(HashMap<String, FormLayoutAnchor> anchors) {
    // Init autoSize Anchor position
    anchors.forEach((anchorName, anchor) {
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
