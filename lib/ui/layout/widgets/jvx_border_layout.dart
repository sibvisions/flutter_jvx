import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';

/// Layout contraints to define widget position:
///           NORTH
/// WEST    CENTER      EAST
///           SOUTH
enum JVxBorderLayoutConstraints {
  North,
  South,
  West,
  East,
  Center
}


JVxBorderLayoutConstraints getJVxBorderLayoutConstraintsFromString(String jvxBorderLayoutConstraintsString) {
  jvxBorderLayoutConstraintsString = 'JVxBorderLayoutConstraints.$jvxBorderLayoutConstraintsString';
  return JVxBorderLayoutConstraints.values.firstWhere((f)=> f.toString() == jvxBorderLayoutConstraintsString, orElse: () => null);
}

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
class JVxBorderLayoutWidget extends MultiChildRenderObjectWidget {
  final int iHorizontalGap;
  final int iVerticalGap;
  final EdgeInsets insMargin;

  JVxBorderLayoutWidget({
    Key key,
    List<JVxBorderLayoutId> children: const [],
    this.insMargin = EdgeInsets.zero,
    this.iHorizontalGap = 0,
    this.iVerticalGap = 0 }) : super (key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderJVxBorderLayoutWidget(this.insMargin, this.iHorizontalGap, this.iVerticalGap);
  }

  @override
  void updateRenderObject(BuildContext context, RenderJVxBorderLayoutWidget renderObject) {

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

class RenderJVxBorderLayoutWidget extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  RenderBox north;
  RenderBox south;
  RenderBox west;
  RenderBox east;
  RenderBox center;
  EdgeInsets insMargin;
  int iHorizontalGap;
  int iVerticalGap;

  RenderJVxBorderLayoutWidget(this.insMargin, this.iHorizontalGap, this.iVerticalGap, { List<RenderBox> children }) {
    addAll(children);
  }

  void addLayoutComponent(RenderBox pComponent, JVxBorderLayoutConstraints pConstraints)
  {
    if (pConstraints == null || pConstraints==JVxBorderLayoutConstraints.Center)
    {
      center = pComponent;
    }
    else if (pConstraints == JVxBorderLayoutConstraints.North)
    {
      north = pComponent;
    }
    else if (pConstraints == JVxBorderLayoutConstraints.South)
    {
      south = pComponent;
    }
    else if (pConstraints == JVxBorderLayoutConstraints.East)
    {
      east = pComponent;
    }
    else if (pConstraints == JVxBorderLayoutConstraints.West)
    {
      west = pComponent;
    }
    else
    {
      throw new ArgumentError("cannot add to layout: unknown constraint: " + pConstraints.toString());
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
    if (size.width==double.infinity || size.height==double.infinity) {
      print("Infinity height or width for BorderLayout");
      size = Size((size.width==double.infinity?double.maxFinite:size.width),
                  (size.height==double.infinity?double.maxFinite:size.height));
    }

    double x = this.insMargin.left;
    double y = this.insMargin.top;

    double width = size.width - x - this.insMargin.right;
    double height = size.height - y - this.insMargin.bottom;

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
      north.layout(BoxConstraints(minWidth: width, maxWidth: width, minHeight: 0, maxHeight: double.infinity), parentUsesSize: true);
      final MultiChildLayoutParentData childParentData = north.parentData;
      childParentData.offset = Offset(x, y);

      y += north.size.height + iVerticalGap;
      height -= north.size.height + iVerticalGap;
    }

    // layout SOUTH
    if (south != null) {
      south.layout(BoxConstraints(minWidth: width, maxWidth: width, minHeight: 0, maxHeight: double.infinity), parentUsesSize: true);
      final MultiChildLayoutParentData childParentData = south.parentData;
      childParentData.offset = Offset(x, y + height - south.size.height);

      height -= south.size.height + iVerticalGap;
    }

    // layout WEST
    if (west != null) {
      west.layout(BoxConstraints(minWidth: 0, maxWidth: double.infinity, minHeight: height, maxHeight: height), parentUsesSize: true);
      final MultiChildLayoutParentData childParentData = west.parentData;
      childParentData.offset = Offset(x, y);

      x += west.size.width + iHorizontalGap;
      width -= west.size.width + iHorizontalGap;
    }

    // layout EAST
    if (east != null) {
      east.layout(BoxConstraints(minWidth: 0, maxWidth: double.infinity, minHeight: height, maxHeight: height), parentUsesSize: true);
      final MultiChildLayoutParentData childParentData = east.parentData;
      childParentData.offset = Offset(x + width - east.size.width, y);

      width -= east.size.width + iHorizontalGap;
    }

    // layout CENTER
    if (center != null) {
      center.layout(BoxConstraints(minWidth: width, maxWidth: width, minHeight: height, maxHeight: height), parentUsesSize: true);
      final MultiChildLayoutParentData childParentData = center.parentData;
      childParentData.offset = Offset(x, y);
    }

    // borderLayout uses max space available
    this.size = size;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }


  @override
  bool hitTestChildren(HitTestResult result, { Offset position }) {
    return defaultHitTestChildren(result, position: position);
  }

}


class JVxBorderLayoutId extends ParentDataWidget<JVxBorderLayoutWidget> {
  /// Marks a child with an BorderLayoutConstraints layout position.
  ///
  /// The child must not be null.
  JVxBorderLayoutId({
    Key key,
    this.pConstraints,
    @required Widget child
  }) : assert(child != null),
        super(key: key ?? ValueKey<Object>(pConstraints), child: child);

  /// An BorderLayoutConstraints defines the layout position of this child.
  final JVxBorderLayoutConstraints pConstraints;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is MultiChildLayoutParentData);
    final MultiChildLayoutParentData parentData = renderObject.parentData;
    if (parentData.id != pConstraints) {
      parentData.id = pConstraints;
      final AbstractNode targetParent = renderObject.parent;
      if (targetParent is RenderObject)
        targetParent.markNeedsLayout();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object>('id', pConstraints));
  }
}