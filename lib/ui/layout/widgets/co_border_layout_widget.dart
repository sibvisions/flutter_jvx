import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import '../../../ui/container/co_container.dart';
import '../../component/component.dart';
import 'co_border_layout_constraint.dart';

///
/// The <code>JVxSequenceLayout</code> can be used as {@link java.awt.FlowLayout} with
/// additional features. The additional features are:
/// <ul>
/// <li>stretch all components to the maximum size of the greatest component</li>
/// <li>en-/disable wrapping when the width/height changes</li>
/// <li>margins</li>
/// </ul>
///
/// @author René Jahn, ported by Jürgen Hörmann
///
class CoBorderLayoutWidget extends MultiChildRenderObjectWidget {
  final int iHorizontalGap;
  final int iVerticalGap;
  final EdgeInsets insMargin;
  final CoContainer container;

  CoBorderLayoutWidget(
      {Key key,
      List<CoBorderLayoutId> children: const [],
      this.container,
      this.insMargin = EdgeInsets.zero,
      this.iHorizontalGap = 0,
      this.iVerticalGap = 0})
      : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderBorderLayoutWidget(
        this.container, this.insMargin, this.iHorizontalGap, this.iVerticalGap);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderBorderLayoutWidget renderObject) {
    /// Force Layout, if some of the settings have changed
    if (renderObject.iHorizontalGap != this.iHorizontalGap) {
      renderObject.iHorizontalGap = this.iHorizontalGap;
      renderObject.markNeedsLayout();
    }

    if (renderObject.iVerticalGap != this.iVerticalGap) {
      renderObject.iVerticalGap = this.iVerticalGap;
      renderObject.markNeedsLayout();
    }

    if (renderObject.insMargin != this.insMargin) {
      renderObject.insMargin = this.insMargin;
      renderObject.markNeedsLayout();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(new IntProperty('iHorizontalGap', iHorizontalGap));
    properties.add(new IntProperty('iVerticalGap', iVerticalGap));
    properties.add(new StringProperty('insMargin', insMargin.toString()));
  }
}

class RenderBorderLayoutWidget extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  RenderBox north;
  Component northComp;
  RenderBox south;
  Component southComp;
  RenderBox west;
  Component westComp;
  RenderBox east;
  Component eastComp;
  RenderBox center;
  Component centerComp;
  EdgeInsets insMargin;
  int iHorizontalGap;
  int iVerticalGap;
  CoContainer container;

  RenderBorderLayoutWidget(
      this.container, this.insMargin, this.iHorizontalGap, this.iVerticalGap,
      {List<RenderBox> children}) {
    addAll(children);
  }

  void addLayoutComponent(
      RenderBox pComponent, CoBorderLayoutConstraintData pConstraints) {
    if (pConstraints == null ||
        pConstraints.constraints == CoBorderLayoutConstraints.Center) {
      center = pComponent;
      centerComp = pConstraints.comp;
    } else if (pConstraints.constraints == CoBorderLayoutConstraints.North) {
      north = pComponent;
      northComp = pConstraints.comp;
    } else if (pConstraints.constraints == CoBorderLayoutConstraints.South) {
      south = pComponent;
      southComp = pConstraints.comp;
    } else if (pConstraints.constraints == CoBorderLayoutConstraints.East) {
      east = pComponent;
      eastComp = pConstraints.comp;
    } else if (pConstraints.constraints == CoBorderLayoutConstraints.West) {
      west = pComponent;
      westComp = pConstraints.comp;
    } else {
      throw new ArgumentError("cannot add to layout: unknown constraint: " +
          pConstraints.toString());
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiChildLayoutParentData)
      child.parentData = MultiChildLayoutParentData();
  }

  @override
  void performLayout() {
    Size size = this.constraints.biggest;
    /*if (size.width==double.infinity || size.height==double.infinity) {
      if (container.isPreferredSizeSet)
        size = this.container.preferredSize;
    }*/

    /*if (size.width==double.infinity || size.height==double.infinity) {
      print("Infinity height or width for BorderLayout");
      size = Size((size.width==double.infinity?double.maxFinite:size.width),
                  (size.height==double.infinity?double.maxFinite:size.height));
    }*/

    double x = this.insMargin.left;
    double y = this.insMargin.top;

    double width = size.width - x - this.insMargin.right;
    double height = size.height - y - this.insMargin.bottom;

    double layoutWidth = 0;
    double layoutHeight = 0;
    double layoutMiddleWidth = 0;
    double layoutMiddleHeight = 0;

    // Set components
    this.north = null;
    this.south = null;
    this.east = null;
    this.west = null;
    this.center = null;

    RenderBox child = firstChild;
    while (child != null) {
      final MultiChildLayoutParentData childParentData = child.parentData;
      addLayoutComponent(child, childParentData.id);

      child = childParentData.nextSibling;
    }

    // layout NORTH
    if (north != null) {
      double minWidth = width;
      double minHeight = 0;
      double maxHeight = double.infinity;

      if (northComp.isPreferredSizeSet) {
        maxHeight = northComp.preferredSize.height;
        //minHeight = maxHeight;
      }

      if (minWidth == double.infinity) minWidth = 0;

      north.layout(
          BoxConstraints(
              minWidth: minWidth,
              maxWidth: width,
              minHeight: minHeight,
              maxHeight: maxHeight),
          parentUsesSize: true);
      final MultiChildLayoutParentData childParentData = north.parentData;
      childParentData.offset = Offset(x, y);

      y += north.size.height + iVerticalGap;
      height -= north.size.height + iVerticalGap;
      layoutWidth += north.size.width;
      layoutHeight += north.size.height;
    }

    // layout SOUTH
    if (south != null) {
      double minWidth = width;
      double minHeight = 0;
      double maxHeight = double.infinity;

      if (southComp.isPreferredSizeSet) {
        maxHeight = southComp.preferredSize.height;
        //minHeight = maxHeight;
      }

      if (minWidth == double.infinity) minWidth = 0;

      south.layout(
          BoxConstraints(
              minWidth: minWidth,
              maxWidth: width,
              minHeight: minHeight,
              maxHeight: maxHeight),
          parentUsesSize: true);
      final MultiChildLayoutParentData childParentData = south.parentData;
      childParentData.offset = Offset(x, y + height - south.size.height);

      height -= south.size.height + iVerticalGap;
      layoutWidth = max(south.size.width, layoutWidth);
      layoutHeight += south.size.height;
    }

    // layout WEST
    if (west != null) {
      double minHeight = height;
      double minWidth = 0;
      double maxWidth = double.infinity;

      if (westComp.isPreferredSizeSet) {
        maxWidth = westComp.preferredSize.width;
        //minHeight = maxHeight;
      }

      if (minHeight == double.infinity) minHeight = 0;

      west.layout(
          BoxConstraints(
              minWidth: minWidth,
              maxWidth: maxWidth,
              minHeight: minHeight,
              maxHeight: height),
          parentUsesSize: true);
      final MultiChildLayoutParentData childParentData = west.parentData;
      childParentData.offset = Offset(x, y);

      x += west.size.width + iHorizontalGap;
      width -= west.size.width + iHorizontalGap;
      layoutMiddleWidth += west.size.width + iHorizontalGap;
      layoutMiddleHeight =
          max(west.size.height + iVerticalGap, layoutMiddleHeight);
    }

    // layout EAST
    if (east != null) {
      double minHeight = height;
      double minWidth = 0;
      double maxWidth = double.infinity;

      if (eastComp.isPreferredSizeSet) {
        maxWidth = eastComp.preferredSize.width;
        //minHeight = maxHeight;
      }

      if (minHeight == double.infinity) minHeight = 0;

      east.layout(
          BoxConstraints(
              minWidth: minWidth,
              maxWidth: maxWidth,
              minHeight: minHeight,
              maxHeight: height),
          parentUsesSize: true);
      final MultiChildLayoutParentData childParentData = east.parentData;
      childParentData.offset = Offset(x + width - east.size.width, y);

      width -= east.size.width + iHorizontalGap;
      layoutMiddleWidth += east.size.width + iHorizontalGap;
      layoutMiddleHeight =
          max(east.size.height + iVerticalGap, layoutMiddleHeight);
    }

    // layout CENTER
    if (center != null) {
      double minHeight = height;
      double minWidth = width;

      if (minHeight == double.infinity) minHeight = 0;

      if (minWidth == double.infinity) minWidth = 0;

      if (height == double.infinity && centerComp.isPreferredSizeSet) {
        height = centerComp.preferredSize.height;
        minHeight = height;
      }

      if (width == double.infinity && centerComp.isPreferredSizeSet) {
        width = centerComp.preferredSize.width;
        minWidth = width;
      }

      center.layout(
          BoxConstraints(
              minWidth: minWidth,
              maxWidth: width,
              minHeight: minHeight,
              maxHeight: height),
          parentUsesSize: true);
      final MultiChildLayoutParentData childParentData = center.parentData;
      childParentData.offset = Offset(x, y);
      layoutMiddleWidth += center.size.width + iHorizontalGap;
      layoutMiddleHeight =
          max(center.size.height + iVerticalGap, layoutMiddleHeight);
    }

    layoutWidth = max(layoutWidth, layoutMiddleWidth);
    layoutHeight += layoutMiddleHeight;

    // borderLayout uses max space available
    this.size = this.constraints.constrainDimensions(layoutWidth, layoutHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(HitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

class CoBorderLayoutId extends ParentDataWidget<MultiChildLayoutParentData> {
  /// Marks a child with an BorderLayoutConstraints layout position.
  ///
  /// The child must not be null.
  CoBorderLayoutId({Key key, this.pConstraints, @required Widget child})
      : assert(child != null),
        super(key: key ?? ValueKey<Object>(pConstraints), child: child);

  /// An BorderLayoutConstraints defines the layout position of this child.
  final CoBorderLayoutConstraintData pConstraints;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is MultiChildLayoutParentData);
    final MultiChildLayoutParentData parentData = renderObject.parentData;
    if (parentData.id != pConstraints) {
      parentData.id = pConstraints;
      final AbstractNode targetParent = renderObject.parent;
      if (targetParent is RenderObject) targetParent.markNeedsLayout();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object>('id', pConstraints));
  }

  @override
  Type get debugTypicalAncestorWidgetClass => MultiChildLayoutParentData;
}
