import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterclient/src/ui/container/models/container_component_model.dart';
import 'package:flutterclient/src/ui/layout/layout/i_layout_model.dart';
import 'package:flutterclient/src/ui/layout/layout/layout_model.dart';

import '../../component/component_widget.dart';
import '../../container/co_container_widget.dart';
import 'co_border_layout_constraint.dart';
import 'co_layout_render_box.dart';

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
  final CoContainerWidget? container;
  final LayoutState layoutState;

  CoBorderLayoutWidget(
      {Key? key,
      List<CoBorderLayoutId> children: const [],
      this.container,
      this.insMargin = EdgeInsets.zero,
      this.iHorizontalGap = 0,
      this.iVerticalGap = 0,
      required this.layoutState})
      : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderBorderLayoutWidget(this.container!, this.insMargin,
        this.iHorizontalGap, this.iVerticalGap, this.layoutState);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderBorderLayoutWidget renderObject) {
    /// Force Layout, if some of the settings have changed
    if (this.layoutState == LayoutState.DIRTY) {
      renderObject.markNeedsLayout();
    }

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

class RenderBorderLayoutWidget extends CoLayoutRenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  RenderBox? north;
  ComponentWidget? northComp;
  RenderBox? south;
  ComponentWidget? southComp;
  RenderBox? west;
  ComponentWidget? westComp;
  RenderBox? east;
  ComponentWidget? eastComp;
  RenderBox? center;
  ComponentWidget? centerComp;
  EdgeInsets? insMargin;
  int? iHorizontalGap;
  int? iVerticalGap;
  CoContainerWidget? container;
  Map<BoxConstraints, Size> layoutSize = Map<BoxConstraints, Size>();

  LayoutState layoutState;

  RenderBorderLayoutWidget(this.container, this.insMargin, this.iHorizontalGap,
      this.iVerticalGap, this.layoutState,
      {List<RenderBox>? children}) {
    addAll(children);
  }

  @override
  void markNeedsLayout() {
    layoutSize = Map<BoxConstraints, Size>();
    LayoutModel layoutModel =
        (container!.componentModel as ContainerComponentModel)
            .layout!
            .layoutModel;
    layoutModel.layoutPreferredSize = Map<BoxConstraints, Size>();
    layoutModel.layoutMaximumSize = Map<BoxConstraints, Size>();
    layoutModel.layoutMinimumSize = Map<BoxConstraints, Size>();
    super.markNeedsLayout();
  }

  void addLayoutComponent(
      RenderBox pComponent, CoBorderLayoutConstraintData pConstraints) {
    if (pConstraints.constraints == CoBorderLayoutConstraints.Center) {
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
    this.debugInfo =
        "BorderLayout in container ${container!.componentModel.componentId}";

    Size size = this.constraints.biggest;
    double x = this.insMargin!.left;
    double y = this.insMargin!.top;

    double width = size.width - x - this.insMargin!.right;
    double height = size.height - y - this.insMargin!.bottom;

    double layoutWidth = 0;
    double layoutHeight = 0;
    double layoutMiddleWidth = 0;
    double layoutMiddleHeight = 0;

    double globalMaxWidth = 0;
    double globalMaxWidthCenterRow = 0;

    // Set components
    this.north = null;
    this.south = null;
    this.east = null;
    this.west = null;
    this.center = null;

    RenderBox? child = firstChild;
    while (child != null) {
      final MultiChildLayoutParentData childParentData =
          child.parentData as MultiChildLayoutParentData;
      addLayoutComponent(
          child, childParentData.id as CoBorderLayoutConstraintData);

      child = childParentData.nextSibling;
    }

    if (layoutSize[this.constraints] != null)
      this.size = layoutSize[this.constraints]!;
    else {
      LayoutModel layoutModel =
          (container?.componentModel as ContainerComponentModel)
              .layout!
              .layoutModel;

      // calculate preferred, minimum and maximum layout sizes for parent layouts
      // preferredLayoutSize = layoutModel.layoutPreferredSize[this.constraints];
      // if (preferredLayoutSize == null) {
      //   preferredLayoutSize = _preferredLayoutSize(
      //       container?.componentModel as ContainerComponentModel);
      //   if (preferredLayoutSize != null)
      //     layoutModel.layoutPreferredSize[this.constraints] =
      //         preferredLayoutSize!;
      // }

      // minimumLayoutSize = layoutModel.layoutMinimumSize[this.constraints];
      // if (minimumLayoutSize == null) {
      //   minimumLayoutSize = _minimumLayoutSize(
      //       container?.componentModel as ContainerComponentModel);
      //   if (minimumLayoutSize != null)
      //     layoutModel.layoutMinimumSize[this.constraints] = minimumLayoutSize!;
      // }

      // maximumLayoutSize = layoutModel.layoutMaximumSize[this.constraints];
      // if (maximumLayoutSize == null) {
      //   maximumLayoutSize = _maximumLayoutSize(
      //       container?.componentModel as ContainerComponentModel);
      //   if (maximumLayoutSize != null)
      //     layoutModel.layoutMaximumSize[this.constraints] = maximumLayoutSize!;
      // }

      // layout NORTH
      if (north != null) {
        double minWidth = width;
        double minHeight = 0;
        double maxHeight = double.infinity;

        if (northComp!.componentModel.isPreferredSizeSet) {
          maxHeight = northComp!.componentModel.preferredSize!.height;
        }

        if (minWidth == double.infinity) minWidth = 0;

        Size size = layoutRenderBox(
            north!,
            BoxConstraints(
                minWidth: minWidth,
                maxWidth: width,
                minHeight: minHeight,
                maxHeight: maxHeight));
        final MultiChildLayoutParentData childParentData =
            north!.parentData as MultiChildLayoutParentData;
        childParentData.offset = Offset(x, y);

        y += size.height + iVerticalGap!;
        height -= size.height + iVerticalGap!;
        layoutWidth += size.width;
        layoutHeight += size.height;
        globalMaxWidth = size.width;
      }

      // layout SOUTH
      if (south != null) {
        double minWidth = width;
        double minHeight = 0;
        double maxHeight = double.infinity;

        if (globalMaxWidth > minHeight) minHeight = globalMaxWidth;

        if (southComp!.componentModel.isPreferredSizeSet) {
          maxHeight = southComp!.componentModel.preferredSize!.height;
        }

        if (minWidth == double.infinity) minWidth = 0;

        Size size = layoutRenderBox(
            south!,
            BoxConstraints(
                minWidth: minWidth,
                maxWidth: width,
                minHeight: minHeight,
                maxHeight: maxHeight));
        final MultiChildLayoutParentData childParentData =
            south!.parentData as MultiChildLayoutParentData;
        childParentData.offset = Offset(x, y + height - size.height);

        height -= size.height + iVerticalGap!;
        layoutWidth = max(size.width, layoutWidth);
        layoutHeight += size.height;

        if (size.width > globalMaxWidth) globalMaxWidth = size.width;
      }

      // layout WEST
      if (west != null) {
        double minHeight = height;
        double minWidth = 0;
        double maxWidth = double.infinity;

        if (westComp!.componentModel.isPreferredSizeSet) {
          maxWidth = westComp!.componentModel.preferredSize!.width;
        }

        if (minHeight == double.infinity) minHeight = 0;

        Size size = layoutRenderBox(
            west!,
            BoxConstraints(
                minWidth: minWidth,
                maxWidth: maxWidth,
                minHeight: minHeight,
                maxHeight: height));
        final MultiChildLayoutParentData childParentData =
            west!.parentData as MultiChildLayoutParentData;
        childParentData.offset = Offset(x, y);

        x += size.width + iHorizontalGap!;
        width -= size.width + iHorizontalGap!;
        layoutMiddleWidth += size.width + iHorizontalGap!;
        layoutMiddleHeight =
            max(size.height + iVerticalGap!, layoutMiddleHeight);
        globalMaxWidthCenterRow = size.width;
      }

      // layout EAST
      if (east != null) {
        double minHeight = height;
        double minWidth = 0;
        double maxWidth = double.infinity;

        if (eastComp!.componentModel.isPreferredSizeSet) {
          maxWidth = eastComp!.componentModel.preferredSize!.width;
        }

        if (minHeight == double.infinity) minHeight = 0;

        Size size = layoutRenderBox(
            east!,
            BoxConstraints(
                minWidth: minWidth,
                maxWidth: maxWidth,
                minHeight: minHeight,
                maxHeight: height));
        final MultiChildLayoutParentData childParentData =
            east!.parentData as MultiChildLayoutParentData;
        childParentData.offset = Offset(x + width - size.width, y);

        width -= size.width + iHorizontalGap!;
        layoutMiddleWidth += size.width + iHorizontalGap!;
        layoutMiddleHeight =
            max(size.height + iVerticalGap!, layoutMiddleHeight);
        globalMaxWidthCenterRow += size.width;
      }

      // layout CENTER
      if (center != null) {
        double minHeight = height;
        double minWidth = width;

        if (minHeight == double.infinity) minHeight = 0;

        if (minWidth == double.infinity) minWidth = 0;

        if (height == double.infinity &&
            centerComp!.componentModel.isPreferredSizeSet) {
          height = centerComp!.componentModel.preferredSize!.height;
          minHeight = height;
        }

        if (width == double.infinity &&
            centerComp!.componentModel.isPreferredSizeSet) {
          width = centerComp!.componentModel.preferredSize!.width;
          minWidth = width;
        }

        if (globalMaxWidth - globalMaxWidthCenterRow > minWidth) {
          minWidth = globalMaxWidth - globalMaxWidthCenterRow;
          if (width < minWidth) width = minWidth;
        }

        Size size = layoutRenderBox(
            center!,
            BoxConstraints(
                minWidth: minWidth,
                maxWidth: width,
                minHeight: minHeight,
                maxHeight: height));
        final MultiChildLayoutParentData childParentData =
            center!.parentData as MultiChildLayoutParentData;
        childParentData.offset = Offset(x, y);
        layoutMiddleWidth += size.width + iHorizontalGap!;
        layoutMiddleHeight =
            max(size.height + iVerticalGap!, layoutMiddleHeight);
      }

      layoutWidth = max(layoutWidth, layoutMiddleWidth);
      layoutHeight += layoutMiddleHeight;

      // borderLayout uses max space available
      this.size =
          this.constraints.constrainDimensions(layoutWidth, layoutHeight);

      if (this.constraints.hasBoundedHeight &&
          this.constraints.hasBoundedWidth) {
        layoutState = LayoutState.RENDERED;
      }

      //layoutSize[this.constraints] = Size(this.size.width, this.size.height);

      dev.log(
          "BorderLayout in Container ${container!.componentModel.name} (${container!.componentModel.componentId}) with constraints ${this.constraints} render size ${this.size.toString()}");
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  Size _minimumLayoutSize(ContainerComponentModel pTarget) {
    if (pTarget.isMinimumSizeSet) {
      return pTarget.minimumSize!;
    } else {
      Size n;
      if (north == null) {
        n = new Size(0, 0);
      } else {
        n = this.getMinimumSize(
            north!,
            BoxConstraints(
                minHeight: 0,
                minWidth: 0,
                maxHeight: double.infinity,
                maxWidth: double.infinity),
            northComp!)!;
        n = Size(n.width, n.height + iVerticalGap!);
      }
      Size w;
      if (west == null) {
        w = new Size(0, 0);
      } else {
        w = this.getMinimumSize(
            west!,
            BoxConstraints(
                minHeight: 0,
                minWidth: 0,
                maxHeight: double.infinity,
                maxWidth: double.infinity),
            westComp!)!;
        w = Size(w.width + iHorizontalGap!, w.height);
      }
      Size c;
      if (center == null) {
        c = new Size(0, 0);
      } else {
        c = this.getMinimumSize(
            center!,
            BoxConstraints(
                minHeight: 0,
                minWidth: 0,
                maxHeight: double.infinity,
                maxWidth: double.infinity),
            centerComp!)!;
      }
      Size e;
      if (east == null) {
        e = new Size(0, 0);
      } else {
        e = this.getMinimumSize(
            east!,
            BoxConstraints(
                minHeight: 0,
                minWidth: 0,
                maxHeight: double.infinity,
                maxWidth: double.infinity),
            eastComp!)!;
        e = Size(e.width + iHorizontalGap!, e.height);
      }
      Size s;
      if (south == null) {
        s = new Size(0, 0);
      } else {
        s = this.getMinimumSize(
            south!,
            BoxConstraints(
                minHeight: 0,
                minWidth: 0,
                maxHeight: double.infinity,
                maxWidth: double.infinity),
            southComp!)!;
        s = Size(s.width, s.height + iVerticalGap!);
      }

      return new Size(max(max(n.width, s.width), w.width + c.width + e.width),
          max(max(w.height, e.height), c.height) + n.height + s.height);
    }
  }

  Size _maximumLayoutSize(ContainerComponentModel pTarget) {
    if (pTarget.isMaximumSizeSet) {
      return pTarget.maximumSize!;
    } else {
      return new Size(double.maxFinite, double.maxFinite);
    }
  }

  Size _preferredLayoutSize(ContainerComponentModel pContainer) {
    double width = 0;
    double height = 0;

    double maxWidth = 0;
    double maxHeight = 0;
    if (north != null) {
      Size size = this.getPreferredSize(
          north!,
          BoxConstraints(
              minHeight: 0,
              minWidth: 0,
              maxHeight: double.infinity,
              maxWidth: double.infinity),
          northComp!)!;

      maxWidth = size.width;
      height += size.height + iVerticalGap!;
    }
    if (south != null) {
      Size size = this.getPreferredSize(
          south!,
          BoxConstraints(
              minHeight: 0,
              minWidth: 0,
              maxHeight: double.infinity,
              maxWidth: double.infinity),
          southComp!)!;

      if (size.width > maxWidth) {
        maxWidth = size.width;
      }
      height += size.height + iVerticalGap!;
    }
    if (west != null) {
      Size size = this.getPreferredSize(
          west!,
          BoxConstraints(
              minHeight: 0,
              minWidth: 0,
              maxHeight: double.infinity,
              maxWidth: double.infinity),
          westComp!)!;

      maxHeight = size.height;
      width += size.width + iHorizontalGap!;
    }
    if (east != null) {
      Size size = this.getPreferredSize(
          east!,
          BoxConstraints(
              minHeight: 0,
              minWidth: 0,
              maxHeight: double.infinity,
              maxWidth: double.infinity),
          eastComp!)!;

      if (size.height > maxHeight) {
        maxHeight = size.height;
      }
      width += size.width + iHorizontalGap!;
    }
    if (center != null) {
      Size size = this.getPreferredSize(
          center!,
          BoxConstraints(
              minHeight: 0,
              minWidth: 0,
              maxHeight: double.infinity,
              maxWidth: double.infinity),
          centerComp!)!;
      if (size.height > maxHeight) {
        maxHeight = size.height;
      }
      width += size.width;
    }
    height += maxHeight;
    if (maxWidth > width) {
      width = maxWidth;
    }

    EdgeInsets insets = EdgeInsets.all(0);
    // pContainer.getInsets();

    return new Size(
        width + insets.left + insets.right + insMargin!.left + insMargin!.right,
        height +
            insets.top +
            insets.bottom +
            insMargin!.top +
            insMargin!.bottom);
  }

  Size? getPreferredSize(
      RenderBox renderBox, BoxConstraints constraints, ComponentWidget comp) {
    if (!comp.componentModel.isPreferredSizeSet) {
      Size? size = getChildLayoutPreferredSize(comp, this.constraints);
      if (size != null) {
        return size;
      } else {
        if (renderBox.hasSize && _childSize(comp) != null)
          size = renderBox.size;
        else
          size = layoutRenderBox(renderBox, constraints);

        if (size.width == double.infinity || size.height == double.infinity) {
          print(
              "CoBorderLayout: getPrefererredSize: Infinity height or width for BorderLayout!");
        }
        //_setChildSize(comp, size);
        return size;
      }
    } else {
      return comp.componentModel.preferredSize;
    }
  }

  Size? getMinimumSize(
      RenderBox renderBox, BoxConstraints constraints, ComponentWidget comp) {
    if (!comp.componentModel.isMinimumSizeSet) {
      Size? size = getChildLayoutMinimumSize(comp, this.constraints);
      if (size != null)
        return size;
      else {
        Size size = layoutRenderBox(renderBox, constraints);
        //renderBox.layout(constraints, parentUsesSize: true);

        if (size.width == double.infinity || size.height == double.infinity) {
          print(
              "CoBorderLayout: getMinimumSize: Infinity height or width for BorderLayout!");
        }
        return size;
      }
    } else {
      return comp.componentModel.minimumSize;
    }
  }

  bool _isLayoutDirty(ComponentWidget comp) {
    if (comp is CoContainerWidget) {
      ContainerComponentModel containerComponentModel =
          comp.componentModel as ContainerComponentModel;

      if (containerComponentModel.layout != null &&
          containerComponentModel.layout!.layoutModel.layoutState ==
              LayoutState.DIRTY) {
        // containerComponentModel.layout!.layoutModel.layoutState =
        //     LayoutState.RENDERED;
        return true;
      }
    }

    return false;
  }

  Size? _childSize(ComponentWidget comp) {
    if (comp is CoContainerWidget) {
      ContainerComponentModel containerComponentModel =
          comp.componentModel as ContainerComponentModel;

      if (containerComponentModel.layout != null) {
        return containerComponentModel.layout!.layoutModel.layoutSize;
      }
    }

    return null;
  }

  void _setChildSize(ComponentWidget comp, Size size) {
    if (comp is CoContainerWidget) {
      ContainerComponentModel containerComponentModel =
          comp.componentModel as ContainerComponentModel;

      if (containerComponentModel.layout != null) {
        containerComponentModel.layout!.layoutModel.layoutSize = size;
      }
    }
  }
}

class CoBorderLayoutId extends ParentDataWidget<MultiChildLayoutParentData> {
  /// Marks a child with an BorderLayoutConstraints layout position.
  ///
  /// The child must not be null.
  CoBorderLayoutId(
      {Key? key, required this.pConstraints, required Widget child})
      : super(key: key ?? ValueKey<Object>(pConstraints), child: child);

  /// An BorderLayoutConstraints defines the layout position of this child.
  final CoBorderLayoutConstraintData pConstraints;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is MultiChildLayoutParentData);
    final MultiChildLayoutParentData parentData =
        renderObject.parentData as MultiChildLayoutParentData;
    if (parentData.id != pConstraints) {
      parentData.id = pConstraints;
      final AbstractNode targetParent = renderObject.parent!;
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
