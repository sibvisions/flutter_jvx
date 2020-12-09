import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../container/co_container_widget.dart';
import '../../container/container_component_model.dart';
import 'co_form_layout_anchor.dart';
import 'co_form_layout_constraint.dart';
import 'co_layout_render_box.dart';

///
/// The FormLayout is a simple to use Layout which allows complex forms.
///
/// @author Martin Handsteiner, ported by Jürgen Hörmann
///
class CoFormLayoutWidget extends MultiChildRenderObjectWidget {
  /// The valid state of anchor calculation. */
  final bool valid;

  /// the x-axis alignment (default: {@link JVxConstants#CENTER}). */
  final int horizontalAlignment;

  /// the y-axis alignment (default: {@link JVxConstants#CENTER}). */
  final int verticalAlignment;

  /// The horizontal gap. */
  final int hgap;

  /// The vertical gap. */
  final vgap;

  /// The left border anchor. */
  final CoFormLayoutAnchor leftAnchor;

  /// The left border anchor. */
  final CoFormLayoutAnchor rightAnchor;

  /// The left border anchor. */
  final CoFormLayoutAnchor topAnchor;

  /// The left border anchor. */
  final CoFormLayoutAnchor bottomAnchor;

  /// The left margin border anchor. */
  final CoFormLayoutAnchor leftMarginAnchor;

  /// The left margin border anchor. */
  final CoFormLayoutAnchor rightMarginAnchor;

  /// The left margin border anchor. */
  final CoFormLayoutAnchor topMarginAnchor;

  /// The left margin border anchor. */
  final CoFormLayoutAnchor bottomMarginAnchor;

  final CoContainerWidget container;

  CoFormLayoutWidget(
      {Key key,
      List<CoFormLayoutConstraintData> children: const [],
      this.container,
      this.valid,
      this.horizontalAlignment,
      this.verticalAlignment,
      this.hgap,
      this.vgap,
      this.leftAnchor,
      this.rightAnchor,
      this.topAnchor,
      this.bottomAnchor,
      this.leftMarginAnchor,
      this.rightMarginAnchor,
      this.topMarginAnchor,
      this.bottomMarginAnchor})
      : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderFormLayoutWidget(
        this.container,
        this.valid,
        this.horizontalAlignment,
        this.verticalAlignment,
        this.hgap,
        this.vgap,
        this.leftAnchor,
        this.rightAnchor,
        this.topAnchor,
        this.bottomAnchor,
        this.leftMarginAnchor,
        this.rightMarginAnchor,
        this.topMarginAnchor,
        this.bottomMarginAnchor);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderFormLayoutWidget renderObject) {
    /// Force Layout, if some of the settings have changed
    if (renderObject.valid != this.valid) {
      renderObject.valid = this.valid;
      renderObject.markNeedsLayout();
    }

    if (renderObject.horizontalAlignment != this.horizontalAlignment) {
      renderObject.horizontalAlignment = this.horizontalAlignment;
      renderObject.markNeedsLayout();
    }

    if (renderObject.verticalAlignment != this.verticalAlignment) {
      renderObject.verticalAlignment = this.verticalAlignment;
      renderObject.markNeedsLayout();
    }

    if (renderObject.hgap != this.hgap) {
      renderObject.hgap = this.hgap;
      renderObject.markNeedsLayout();
    }

    if (renderObject.vgap != this.vgap) {
      renderObject.vgap = this.vgap;
      renderObject.markNeedsLayout();
    }

    if (renderObject.leftAnchor != this.leftAnchor) {
      renderObject.leftAnchor = this.leftAnchor;
      renderObject.markNeedsLayout();
    }

    if (renderObject.container != this.container) {
      renderObject.container = this.container;
      renderObject.markNeedsLayout();
    }
  }
}

class RenderFormLayoutWidget extends CoLayoutRenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  ///~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  /// Class members
  ///~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  BoxConstraints formConstraints;

  /// Constraint for starting a new row for the given component.
  static final String newLine = "\n";
  static final int intMax = pow(2, 31) - 1;
  static final int stretch = 3;
  static final int left = 0;
  static final int right = 2;
  static final int top = 0;
  static final int bottom = 2;

  /// The left border anchor. */
  CoFormLayoutAnchor leftAnchor;

  /// The left border anchor. */
  CoFormLayoutAnchor rightAnchor;

  /// The left border anchor. */
  CoFormLayoutAnchor topAnchor;

  /// The left border anchor. */
  CoFormLayoutAnchor bottomAnchor;

  /// The left margin border anchor. */
  CoFormLayoutAnchor leftMarginAnchor;

  /// The left margin border anchor. */
  CoFormLayoutAnchor rightMarginAnchor;

  /// The left margin border anchor. */
  CoFormLayoutAnchor topMarginAnchor;

  /// The left margin border anchor. */
  CoFormLayoutAnchor bottomMarginAnchor;

  /// All horizontal anchors. */
  List<CoFormLayoutAnchor> horizontalAnchors;

  /// All vertical anchors. */
  List<CoFormLayoutAnchor> verticalAnchors;

  /// All vertical anchors. */
  List<CoFormLayoutAnchor> anchorsBuffer;

  /// stores all constraints. */
  Map<RenderBox, CoFormLayoutConstraint> layoutConstraints =
      <RenderBox, CoFormLayoutConstraint>{};

  /// the x-axis alignment (default: {@link JVxConstants#CENTER}). */
  int horizontalAlignment = stretch;

  /// the y-axis alignment (default: {@link JVxConstants#CENTER}). */
  int verticalAlignment = stretch;

  /// The horizontal gap. */
  int hgap = 5;

  /// The vertical gap. */
  int vgap = 5;

  /// The new line count. */
  int newlineCount = 2;

  /// The preferred width. */
  int preferredWidth = 0;

  /// The preferred height. */
  int preferredHeight = 0;

  /// The preferred width. */
  int minimumWidth = 0;

  /// The preferred height. */
  int minimumHeight = 0;

  /// The valid state of anchor calculation. */
  bool valid = false;

  /// True, if the target dependent anchors should be calculated again. */
  bool calculateTargetDependentAnchors = false;

  /// True, if the left border is used by another anchor. */
  bool leftBorderUsed = false;

  /// True, if the right border is used by another anchor. */
  bool rightBorderUsed = false;

  /// True, if the top border is used by another anchor. */
  bool topBorderUsed = false;

  /// True, if the bottom border is used by another anchor. */
  bool bottomBorderUsed = false;

  double layoutWidth = 0;
  double layoutHeight = 0;

  CoContainerWidget container;

  RenderFormLayoutWidget(
      this.container,
      this.valid,
      this.horizontalAlignment,
      this.verticalAlignment,
      this.hgap,
      this.vgap,
      this.leftAnchor,
      this.rightAnchor,
      this.topAnchor,
      this.bottomAnchor,
      this.leftMarginAnchor,
      this.rightMarginAnchor,
      this.topMarginAnchor,
      this.bottomMarginAnchor,
      {List<RenderBox> children}) {
    addAll(children);

    horizontalAnchors = new List<CoFormLayoutAnchor>();
    verticalAnchors = new List<CoFormLayoutAnchor>();
    anchorsBuffer = new List<CoFormLayoutAnchor>();
  }

  void addLayoutComponent(
      RenderBox pComponent, CoFormLayoutConstraint pConstraint) {
    if (pConstraint == null) {
      throw new ArgumentError("CoFromLayout: Constraint " +
          pConstraint.toString() +
          " is not allowed!");
    } else {
      layoutConstraints.putIfAbsent(pComponent, () => pConstraint);
    }

    valid = false;
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiChildLayoutParentData)
      child.parentData = MultiChildLayoutParentData();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(HitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void performLayout() {
    // Set components
    layoutConstraints = <RenderBox, CoFormLayoutConstraint>{};
    RenderBox child = firstChild;
    while (child != null) {
      final MultiChildLayoutParentData childParentData = child.parentData;
      addLayoutComponent(child, childParentData.id);

      child = childParentData.nextSibling;
    }

    // calculate preferred, minimum and maximum layout sizes for parent layouts
    preferredLayoutSize = _preferredLayoutSize(container.componentModel);
    minimumLayoutSize = _minimumLayoutSize(container.componentModel);
    maximumLayoutSize = _maximumLayoutSize(container.componentModel);

    calculateAnchors(container.componentModel);

    layoutWidth = preferredWidth.toDouble();
    layoutHeight = preferredHeight.toDouble();

    if (this.constraints.maxWidth != double.infinity) {
      layoutWidth = this.constraints.maxWidth;
    }

    if (this.constraints.maxHeight != double.infinity) {
      layoutHeight = this.constraints.maxHeight;
    }

    doCalculateTargetDependentAnchors(container);

    // set component bounds.
    for (int i = 0; i < layoutConstraints.length; i++) {
      RenderBox comp = this.layoutConstraints.keys.elementAt(i);

      CoFormLayoutConstraint constraint = layoutConstraints.values.elementAt(i);

      double x = constraint.leftAnchor.getAbsolutePosition().toDouble();
      double width = constraint.rightAnchor.getAbsolutePosition() - x;
      double y = constraint.topAnchor.getAbsolutePosition().toDouble();
      double height = constraint.bottomAnchor.getAbsolutePosition() - y;

      if (width == double.infinity || height == double.infinity) {
        print("CoFormLayout: Infinity height or width for FormLayout");
      } else if (width < 0 || height < 0) {
        print("CoFormLayout: Negative height or width for FormLayout");
        width = (width < 0) ? width * -1 : width;
        height = (height < 0) ? height * -1 : height;
      }

      comp.layout(
          BoxConstraints(
              minWidth: width,
              maxWidth: width,
              minHeight: height,
              maxHeight: height),
          parentUsesSize: true);

      final MultiChildLayoutParentData childParentData = comp.parentData;
      childParentData.offset = Offset(x, y);
    }

    this.valid = true;
    this.size = this.constraints.constrainDimensions(layoutWidth, layoutHeight);
  }

  /*
     * clears auto size position of anchor.
     * 
     * @param pAnchor the left or top anchor.
  */
  void clearAutoSize(
      List<CoFormLayoutAnchor> pAnchorList, CoFormLayoutAnchor pAnchor) {
    while (pAnchor != null && !pAnchorList.contains(pAnchor)) {
      pAnchorList.add(pAnchor);

      pAnchor.relative = pAnchor.autoSize;
      pAnchor.autoSizeCalculated = false;
      pAnchor.firstCalculation = true;
      if (pAnchor.autoSize) {
        pAnchor.position = 0;
      }

      pAnchor = pAnchor.relatedAnchor;
    }
  }

  ///
  /// Gets all auto size anchors between start and end anchor.
  /// @param pStartAnchor start anchor.
  /// @param pEndAnchor end anchor.
  /// @return all auto size anchors between start and end anchor.
  ///
  List<CoFormLayoutAnchor> getAutoSizeAnchorsBetween(
      CoFormLayoutAnchor pStartAnchor, CoFormLayoutAnchor pEndAnchor) {
    anchorsBuffer.clear();
    while (pStartAnchor != null && pStartAnchor != pEndAnchor) {
      if (pStartAnchor.autoSize && !pStartAnchor.autoSizeCalculated) {
        anchorsBuffer.add(pStartAnchor);
      }
      pStartAnchor = pStartAnchor.relatedAnchor;
    }
    if (pStartAnchor == null) {
      anchorsBuffer.clear();
    }
    return anchorsBuffer;
  }

  /*
    * Inits the autosize with negative gap, to ensure the gaps are, as there is no component in this row or column.
    * @param pAnchor the anchor
    */
  void initAutoSizeWithAnchor(CoFormLayoutAnchor pAnchor) {
    if (pAnchor.relatedAnchor != null && pAnchor.relatedAnchor.autoSize) {
      CoFormLayoutAnchor relatedAutoSizeAnchor = pAnchor.relatedAnchor;
      if (relatedAutoSizeAnchor.relatedAnchor != null &&
          !relatedAutoSizeAnchor.relatedAnchor.autoSize) {
        relatedAutoSizeAnchor.position = -pAnchor.position;
      }
    }
  }

  ///
  /// init component auto size position of anchor.
  ///
  /// @param pStartAnchor the start anchor.
  /// @param pEndAnchor the end anchor.
  ///
  void initAutoSize(
      CoFormLayoutAnchor pStartAnchor, CoFormLayoutAnchor pEndAnchor) {
    List<CoFormLayoutAnchor> anchors =
        getAutoSizeAnchorsBetween(pStartAnchor, pEndAnchor);

    for (int i = 0; i < anchors.length; i++) {
      CoFormLayoutAnchor anchor = anchors[i];
      anchor.relative = false;
      if (!anchor.relatedAnchor.autoSize) {
        anchor.position = -anchor.relatedAnchor.position;
      } else {
        anchor.position = 0;
      }
    }
  }

  ///
  /// Marks all touched Autosize anchors as calculated.
  /// @param pLeftTopAnchor the left or top anchor
  /// @param pRightBottomAnchor the right or bottom anchor
  /// @return amount of autosize anchors left.
  ///
  int finishAutoSizeCalculation(CoFormLayoutAnchor pLeftTopAnchor,
      CoFormLayoutAnchor pRightBottomAnchor) {
    List<CoFormLayoutAnchor> anchors =
        getAutoSizeAnchorsBetween(pLeftTopAnchor, pRightBottomAnchor);
    int count = anchors.length;
    for (int i = 0, size = anchors.length; i < size; i++) {
      CoFormLayoutAnchor anchor = anchors[i];
      if (!anchor.firstCalculation) {
        anchor.autoSizeCalculated = true;
        count--;
      }
    }
    return count;
  }

  ///
  /// Calculates the preferred size of component auto size anchors.
  ///
  /// @param pLeftTopAnchor the left or top anchor.
  /// @param pRightBottomAnchor the right or bottom anchor.
  /// @param pPreferredSize the preferred size.
  /// @param pAutoSizeCount the amount of autoSizeCount.
  ///
  void calculateAutoSize(
      CoFormLayoutAnchor pLeftTopAnchor,
      CoFormLayoutAnchor pRightBottomAnchor,
      int pPreferredSize,
      int pAutoSizeCount) {
    List<CoFormLayoutAnchor> anchors =
        getAutoSizeAnchorsBetween(pLeftTopAnchor, pRightBottomAnchor);
    int size = anchors.length;
    if (size ==
        pAutoSizeCount) // && pLeftTopAnchor.getRelatedAnchor() == pRightBottomAnchor)
    {
      int fixedSize = pRightBottomAnchor.getAbsolutePosition() -
          pLeftTopAnchor.getAbsolutePosition();
      for (int i = 0; i < size; i++) {
        fixedSize += anchors[i].position;
      }

      int diffSize = ((pPreferredSize - fixedSize + size - 1) / size).round();
      for (int i = 0; i < size; i++) {
        CoFormLayoutAnchor anchor = anchors[i];
        if (diffSize > -anchor.position) {
          anchor.position = -diffSize;
        }
        anchor.firstCalculation = false;
      }
    }

    anchors = getAutoSizeAnchorsBetween(pRightBottomAnchor, pLeftTopAnchor);
    size = anchors.length;

    if (anchors.length ==
        pAutoSizeCount) // && pRightBottomAnchor.getRelatedAnchor() == pLeftTopAnchor)
    {
      int fixedSize = pRightBottomAnchor.getAbsolutePosition() -
          pLeftTopAnchor.getAbsolutePosition();
      for (int i = 0; i < size; i++) {
        fixedSize -= anchors[i].position;
      }

      int diffSize = ((pPreferredSize - fixedSize + size - 1) / size).round();
      for (int i = 0; i < size; i++) {
        CoFormLayoutAnchor anchor = anchors[i];
        if (diffSize > anchor.position) {
          anchor.position = diffSize;
        }
        anchor.firstCalculation = false;
      }
    }
  }

  Size getPreferredSize(
      RenderBox renderBox, CoFormLayoutConstraint constraint) {
    if (!constraint.comp.componentModel.isPreferredSizeSet) {
      Size size = getChildLayoutPreferredSize(renderBox);

      if (size != null) {
        return size;
      } else {
        if (renderBox.hasSize)
          return renderBox.size;
        else {
          //renderBox.layout(BoxConstraints.tightFor(), parentUsesSize: true);

          int margin = constraint.leftAnchor.getAbsolutePosition() +
              constraint.rightAnchor.getAbsolutePosition();
          BoxConstraints constraints = BoxConstraints(
              minHeight: 0,
              maxHeight: this.constraints.maxHeight,
              minWidth: 0,
              maxWidth: this.constraints.maxWidth - margin < 0
                  ? this.constraints.maxWidth
                  : this.constraints.maxWidth - margin);

          return layoutRenderBox(renderBox, constraints);
          //renderBox.layout(constraints, parentUsesSize: true);
        }
      }

      // if (!renderBox.hasSize) {
      //   print("CoFormLayout: RenderBox has no size after layout!");
      // }

      // if (renderBox.size.width == double.infinity ||
      //     renderBox.size.height == double.infinity) {
      //   print(
      //       "CoFormLayout: getPrefererredSize: Infinity height or width for FormLayout!");
      // }
      // return renderBox.size;
    } else {
      return constraint.comp.componentModel.preferredSize;
    }
  }

  Size getMinimumSize(RenderBox renderBox, CoFormLayoutConstraint constraint) {
    if (!constraint.comp.componentModel.isMinimumSizeSet) {
      Size size = getChildLayoutMinimumSize(renderBox);

      if (size != null) {
        return size;
      } else {
        if (renderBox.hasSize)
          return renderBox.size;
        else {
          return layoutRenderBox(renderBox, BoxConstraints.tightFor());
          // renderBox.layout(BoxConstraints.tightFor(), parentUsesSize: true);

          // if (renderBox.size.width == double.infinity ||
          //     renderBox.size.height == double.infinity) {
          //   print(
          //       "CoFormLayout: getMinimumSize: Infinity height or width for FormLayout!");
          // }
          // return renderBox.size;
        }
      }
    } else {
      return constraint.comp.componentModel.minimumSize;
    }
  }

  ///
  /// Calculates the preferred size of relative anchors.
  ///
  /// @param pLeftTopAnchor the left or top anchor.
  /// @param pRightBottomAnchor the right or bottom anchor.
  /// @param pPreferredSize the preferred size.
  ///
  void calculateRelativeAnchor(CoFormLayoutAnchor pLeftTopAnchor,
      CoFormLayoutAnchor pRightBottomAnchor, int pPreferredSize) {
    if (pLeftTopAnchor.relative) {
      CoFormLayoutAnchor rightBottom = pRightBottomAnchor.getRelativeAnchor();
      if (rightBottom != null && rightBottom != pLeftTopAnchor) {
        int pref = rightBottom.getAbsolutePosition() -
            pRightBottomAnchor.getAbsolutePosition() +
            pPreferredSize;
        int size = rightBottom.relatedAnchor.getAbsolutePosition() -
            pLeftTopAnchor.relatedAnchor.getAbsolutePosition();

        int pos = pref - size;
        if (pos < 0) {
          pos = (pos / 2).round();
        } else {
          pos -= (pos / 2).round();
        }
        if (rightBottom.firstCalculation || pos > rightBottom.position) {
          rightBottom.firstCalculation = false;
          rightBottom.position = pos;
        }
        pos = pref - size - pos;
        if (pLeftTopAnchor.firstCalculation || pos > -pLeftTopAnchor.position) {
          pLeftTopAnchor.firstCalculation = false;
          pLeftTopAnchor.position = -pos;
        }
      }
    } else if (pRightBottomAnchor.relative) {
      CoFormLayoutAnchor leftTop = pLeftTopAnchor.getRelativeAnchor();
      if (leftTop != null && leftTop != pRightBottomAnchor) {
        int pref = pLeftTopAnchor.getAbsolutePosition() -
            leftTop.getAbsolutePosition() +
            pPreferredSize;
        int size = pRightBottomAnchor.relatedAnchor.getAbsolutePosition() -
            leftTop.relatedAnchor.getAbsolutePosition();

        int pos = size - pref;
        if (pos < 0) {
          pos -= (pos / 2).round();
        } else {
          pos = (pos / 2).round();
        }
        if (leftTop.firstCalculation || pos < leftTop.position) {
          leftTop.firstCalculation = false;
          leftTop.position = pos;
        }
        pos = pref - size - pos;
        if (pRightBottomAnchor.firstCalculation ||
            pos > -pRightBottomAnchor.position) {
          pRightBottomAnchor.firstCalculation = false;
          pRightBottomAnchor.position = -pos;
        }
      }
    }
  }

  void calculateAnchors(ContainerComponentModel pContainer) {
    if (!valid) {
      // reset border anchors
      leftAnchor.position = 0;
      rightAnchor.position = 0;
      topAnchor.position = 0;
      bottomAnchor.position = 0;
      // reset preferred size;
      preferredWidth = 0;
      preferredHeight = 0;
      // reset minimum size;
      minimumWidth = 0;
      minimumHeight = 0;
      // reset List of Anchors;
      horizontalAnchors.clear();
      verticalAnchors.clear();

      // clear auto size anchors.
      for (int i = 0; i < this.layoutConstraints.length; i++) {
        CoFormLayoutConstraint constraint =
            layoutConstraints.values.elementAt(i);

        clearAutoSize(horizontalAnchors, constraint.leftAnchor);
        clearAutoSize(horizontalAnchors, constraint.rightAnchor);
        clearAutoSize(verticalAnchors, constraint.topAnchor);
        clearAutoSize(verticalAnchors, constraint.bottomAnchor);
      }
      horizontalAnchors.forEach((anchor) {
        initAutoSizeWithAnchor(anchor);
      });

      verticalAnchors.forEach((anchor) {
        initAutoSizeWithAnchor(anchor);
      });

      // init component auto size anchors.
      for (int i = 0; i < this.layoutConstraints.length; i++) {
        CoFormLayoutConstraint constraint =
            layoutConstraints.values.elementAt(i);

        initAutoSize(constraint.leftAnchor, constraint.rightAnchor);
        initAutoSize(constraint.rightAnchor, constraint.leftAnchor);
        initAutoSize(constraint.topAnchor, constraint.bottomAnchor);
        initAutoSize(constraint.bottomAnchor, constraint.topAnchor);
      }
      int autoSizeCount = 1;

      do {
        // calculate component auto size anchors.
        for (int i = 0; i < this.layoutConstraints.length; i++) {
          RenderBox comp = this.layoutConstraints.keys.elementAt(i);
          //if (comp.isVisible())
          //{
          CoFormLayoutConstraint constraint =
              layoutConstraints.values.elementAt(i);

          Size preferredSize = this.getPreferredSize(comp, constraint);

          calculateAutoSize(constraint.topAnchor, constraint.bottomAnchor,
              preferredSize.height.round(), autoSizeCount);
          calculateAutoSize(constraint.leftAnchor, constraint.rightAnchor,
              preferredSize.width.round(), autoSizeCount);
          //}
        }
        autoSizeCount = intMax;
        for (int i = 0; i < this.layoutConstraints.length; i++) {
          //RenderBox comp = this.layoutConstraints.keys.elementAt(i);
          //if (comp.isVisible())
          //{
          CoFormLayoutConstraint constraint =
              layoutConstraints.values.elementAt(i);

          int count = finishAutoSizeCalculation(
              constraint.leftAnchor, constraint.rightAnchor);
          if (count > 0 && count < autoSizeCount) {
            autoSizeCount = count;
          }
          count = finishAutoSizeCalculation(
              constraint.rightAnchor, constraint.leftAnchor);
          if (count > 0 && count < autoSizeCount) {
            autoSizeCount = count;
          }
          count = finishAutoSizeCalculation(
              constraint.topAnchor, constraint.bottomAnchor);
          if (count > 0 && count < autoSizeCount) {
            autoSizeCount = count;
          }
          count = finishAutoSizeCalculation(
              constraint.bottomAnchor, constraint.topAnchor);
          if (count > 0 && count < autoSizeCount) {
            autoSizeCount = count;
          }
          //}
        }
      } while (autoSizeCount > 0 && autoSizeCount < intMax);

      leftBorderUsed = false;
      rightBorderUsed = false;
      topBorderUsed = false;
      bottomBorderUsed = false;
      int leftWidth = 0;
      int rightWidth = 0;
      int topHeight = 0;
      int bottomHeight = 0;

      // calculate preferredSize.
      for (int i = 0; i < this.layoutConstraints.length; i++) {
        RenderBox comp = this.layoutConstraints.keys.elementAt(i);
        //if (comp.isVisible())
        //{
        CoFormLayoutConstraint constraint =
            layoutConstraints.values.elementAt(i);

        Size preferredSize = getPreferredSize(comp, constraint);
        Size minimumSize = getMinimumSize(comp, constraint);

        if (constraint.rightAnchor.getBorderAnchor() == leftAnchor) {
          int w = constraint.rightAnchor.getAbsolutePosition();
          if (w > leftWidth) {
            leftWidth = w;
          }
          leftBorderUsed = true;
        }
        if (constraint.leftAnchor.getBorderAnchor() == rightAnchor) {
          int w = -constraint.leftAnchor.getAbsolutePosition();
          if (w > rightWidth) {
            rightWidth = w;
          }
          rightBorderUsed = true;
        }
        if (constraint.bottomAnchor.getBorderAnchor() == topAnchor) {
          int h = constraint.bottomAnchor.getAbsolutePosition();
          if (h > topHeight) {
            topHeight = h;
          }
          topBorderUsed = true;
        }
        if (constraint.topAnchor.getBorderAnchor() == bottomAnchor) {
          int h = -constraint.topAnchor.getAbsolutePosition();
          if (h > bottomHeight) {
            bottomHeight = h;
          }
          bottomBorderUsed = true;
        }
        if (constraint.leftAnchor.getBorderAnchor() == leftAnchor &&
            constraint.rightAnchor.getBorderAnchor() == rightAnchor) {
          int w = constraint.leftAnchor.getAbsolutePosition() -
              constraint.rightAnchor.getAbsolutePosition() +
              preferredSize.width.round();
          if (w > preferredWidth) {
            preferredWidth = w;
          }
          w = constraint.leftAnchor.getAbsolutePosition() -
              constraint.rightAnchor.getAbsolutePosition() +
              minimumSize.width.round();
          if (w > minimumWidth) {
            minimumWidth = w;
          }
          leftBorderUsed = true;
          rightBorderUsed = true;
        }
        if (constraint.topAnchor.getBorderAnchor() == topAnchor &&
            constraint.bottomAnchor.getBorderAnchor() == bottomAnchor) {
          int h = constraint.topAnchor.getAbsolutePosition() -
              constraint.bottomAnchor.getAbsolutePosition() +
              preferredSize.height.round();
          if (h > preferredHeight) {
            preferredHeight = h;
          }
          h = constraint.topAnchor.getAbsolutePosition() -
              constraint.bottomAnchor.getAbsolutePosition() +
              minimumSize.height.round();
          if (h > minimumHeight) {
            minimumHeight = h;
          }
          topBorderUsed = true;
          bottomBorderUsed = true;
        }
        //}
      }
      if (leftWidth != 0 && rightWidth != 0) {
        int w = leftWidth + rightWidth + hgap;
        if (w > preferredWidth) {
          preferredWidth = w;
        }
        if (w > minimumWidth) {
          minimumWidth = w;
        }
      } else if (leftWidth != 0) {
        int w = leftWidth - rightMarginAnchor.position;
        if (w > preferredWidth) {
          preferredWidth = w;
        }
        if (w > minimumWidth) {
          minimumWidth = w;
        }
      } else {
        int w = rightWidth + leftMarginAnchor.position;
        if (w > preferredWidth) {
          preferredWidth = w;
        }
        if (w > minimumWidth) {
          minimumWidth = w;
        }
      }
      if (topHeight != 0 && bottomHeight != 0) {
        int h = topHeight + bottomHeight + vgap;
        if (h > preferredHeight) {
          preferredHeight = h;
        }
        if (h > minimumHeight) {
          minimumHeight = h;
        }
      } else if (topHeight != 0) {
        int h = topHeight - bottomMarginAnchor.position;
        if (h > preferredHeight) {
          preferredHeight = h;
        }
        if (h > minimumHeight) {
          minimumHeight = h;
        }
      } else {
        int h = bottomHeight + topMarginAnchor.position;
        if (h > preferredHeight) {
          preferredHeight = h;
        }
        if (h > minimumHeight) {
          minimumHeight = h;
        }
      }

      /*EdgeInsets ins = pTarget.getInsets();

      preferredWidth += ins.left + ins.right;
      preferredHeight += ins.top + ins.bottom;

      minimumWidth += ins.left + ins.right;
      minimumHeight += ins.top + ins.bottom;
      */

      calculateTargetDependentAnchors = true;
      valid = true;
    }
  }

  ///
  /// Calculates all target size dependent anchors.
  /// This can only be done after the target has his correct size.
  ///
  /// @param pTarget the target.
  ///
  void doCalculateTargetDependentAnchors(CoContainerWidget pTarget) {
    if (calculateTargetDependentAnchors) {
      // set border anchors
      Size size = Size(layoutWidth, layoutHeight);
      Size minSize = _minimumLayoutSize(pTarget.componentModel);
      Size maxSize = _maximumLayoutSize(pTarget.componentModel);
      EdgeInsets ins = EdgeInsets.zero;
      size = Size(size.width - ins.left + ins.right,
          size.height - ins.top + ins.bottom);
      minSize = Size(minSize.width - ins.left + ins.right,
          minSize.height - ins.top + ins.bottom);
      maxSize = Size(maxSize.width - ins.left + ins.right,
          maxSize.height - ins.top + ins.bottom);

      if (horizontalAlignment == stretch ||
          (leftBorderUsed && rightBorderUsed)) {
        if (minSize.width > size.width) {
          leftAnchor.position = 0;
          rightAnchor.position = minSize.width.round();
        } else if (maxSize.width < size.width) {
          if (horizontalAlignment == left) {
            leftAnchor.position = 0;
          } else if (horizontalAlignment == right) {
            leftAnchor.position = (size.width - maxSize.width).round();
          } else {
            leftAnchor.position = ((size.width - maxSize.width) / 2).round();
          }
          rightAnchor.position = leftAnchor.position + maxSize.width.round();
        } else {
          leftAnchor.position = 0;
          rightAnchor.position = size.width.round();
        }
      } else {
        if (preferredWidth > size.width) {
          leftAnchor.position = 0;
        } else {
          if (horizontalAlignment == left) {
            leftAnchor.position = 0;
          } else if (horizontalAlignment == right) {
            leftAnchor.position = (size.width - preferredWidth).round();
          } else {
            leftAnchor.position = ((size.width - preferredWidth) / 2).round();
          }
        }
        rightAnchor.position = leftAnchor.position + preferredWidth;
      }
      if (verticalAlignment == stretch || (topBorderUsed && bottomBorderUsed)) {
        if (minSize.height > size.height) {
          topAnchor.position = 0;
          bottomAnchor.position = minSize.height.round();
        } else if (maxSize.height < size.height) {
          if (verticalAlignment == top) {
            topAnchor.position = 0;
          } else if (verticalAlignment == bottom) {
            topAnchor.position = (size.height - maxSize.height).round();
          } else {
            topAnchor.position = ((size.height - maxSize.height) / 2).round();
          }
          bottomAnchor.position = topAnchor.position + maxSize.height;
        } else {
          topAnchor.position = 0;
          bottomAnchor.position = size.height.round();
        }
      } else {
        if (preferredHeight > size.height) {
          topAnchor.position = 0;
        } else {
          if (verticalAlignment == top) {
            topAnchor.position = 0;
          } else if (verticalAlignment == bottom) {
            topAnchor.position = (size.height - preferredHeight).round();
          } else {
            topAnchor.position = ((size.height - preferredHeight) / 2).round();
          }
        }
        bottomAnchor.position = topAnchor.position + preferredHeight;
      }

      leftAnchor.position = leftAnchor.position + ins.left.round();
      rightAnchor.position += ins.left.round();
      topAnchor.position += ins.top.round();
      bottomAnchor.position += ins.top.round();

      // calculate relative anchors.
      for (int i = 0; i < this.layoutConstraints.length; i++) {
        RenderBox comp = this.layoutConstraints.keys.elementAt(i);
        //if (comp.isVisible()) {
        CoFormLayoutConstraint constraint =
            layoutConstraints.values.elementAt(i);

        Size preferredSize = getPreferredSize(comp, constraint);

        calculateRelativeAnchor(constraint.leftAnchor, constraint.rightAnchor,
            preferredSize.width.round());
        calculateRelativeAnchor(constraint.topAnchor, constraint.bottomAnchor,
            preferredSize.height.round());
        //}
      }
      calculateTargetDependentAnchors = false;
    }
  }

  Size _minimumLayoutSize(ContainerComponentModel pTarget) {
    if (pTarget.isMinimumSizeSet) {
      return pTarget.minimumSize;
    } else {
      return new Size(0, 0);
    }
  }

  Size _preferredLayoutSize(ContainerComponentModel pTarget) {
    calculateAnchors(pTarget);

    return Size(preferredWidth.toDouble(), preferredHeight.toDouble());
  }

  Size _maximumLayoutSize(ContainerComponentModel pTarget) {
    if (pTarget.isMaximumSizeSet) {
      return pTarget.maximumSize;
    } else {
      return new Size(double.infinity, double.infinity);
    }
  }
}

class CoFormLayoutConstraintData
    extends ParentDataWidget<MultiChildLayoutParentData> {
  /// Marks a child with a layout identifier.
  ///
  /// Both the child and the id arguments must not be null.
  CoFormLayoutConstraintData({
    Key key,
    this.id,
    @required Widget child,
  })  : assert(child != null),
        super(key: key ?? ValueKey<Object>(id), child: child);

  /// An object representing the identity of this child.
  ///
  /// The [id] needs to be unique among the children that the
  /// [CustomMultiChildLayout] manages.
  final CoFormLayoutConstraint id;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is MultiChildLayoutParentData);
    final MultiChildLayoutParentData parentData = renderObject.parentData;
    if (parentData.id != id) {
      parentData.id = id;
      final AbstractNode targetParent = renderObject.parent;
      if (targetParent is RenderObject) targetParent.markNeedsLayout();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object>('id', id));
  }

  @override
  Type get debugTypicalAncestorWidgetClass => MultiChildLayoutParentData;
}
