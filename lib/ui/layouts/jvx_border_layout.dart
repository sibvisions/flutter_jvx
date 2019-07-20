import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';

/// Layout contraints to define widget position:
///           NORTH
/// WEST    CENTER      EAST
///           SOUTH
enum BorderLayoutConstraints {
  NORTH,
  SOUTH,
  WEST,
  EAST,
  CENTER,
}

/// JVx border layout. Layouts up to 5 widgets with predefined positions.
class JVxBorderLayout extends MultiChildRenderObjectWidget {
  final int iHorizontalGap;
  final int iVerticalGap;
  final EdgeInsets insMargin;

  JVxBorderLayout({
    Key key,
    List<JVxBorderLayoutId> children: const [],
    this.insMargin = EdgeInsets.zero,
    this.iHorizontalGap = 0,
    this.iVerticalGap = 0 }) : super (key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderJVxBorderLayout(this.insMargin, this.iHorizontalGap, this.iVerticalGap);
  }

  @override
  void updateRenderObject(BuildContext context, RenderJVxBorderLayout renderObject) {

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

class RenderJVxBorderLayout extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  Map<Object, RenderBox> _idToChild = <Object, RenderBox>{};
  EdgeInsets insMargin;
  int iHorizontalGap;
  int iVerticalGap;

  bool hasChild(Object childId) => _idToChild[childId] != null;
  RenderBox getChild(Object childId) => _idToChild[childId];

  RenderJVxBorderLayout(this.insMargin, this.iHorizontalGap, this.iVerticalGap, { List<RenderBox> children }) {
    addAll(children);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiChildLayoutParentData)
      child.parentData = MultiChildLayoutParentData();
  }

  @override
  void performLayout() {
    Size size = this.constraints.biggest;

    double x = this.insMargin.left;
    double y = this.insMargin.top;

    double width = size.width - x - this.insMargin.right;
    double height = size.height - y - this.insMargin.bottom;

    // Map RenderBoxes and positions into _idToChild for sequentially calculate Widget
    // position.
    RenderBox child = firstChild;
    while (child != null) {
      final MultiChildLayoutParentData childParentData = child.parentData;
      this._idToChild[childParentData.id] = child;
      child = childParentData.nextSibling;
    }

    // layout NORTH
    if (hasChild(BorderLayoutConstraints.NORTH)) {
      child = getChild(BorderLayoutConstraints.NORTH);
      child.layout(BoxConstraints(minWidth: 0, maxWidth: width, minHeight: 0, maxHeight: height), parentUsesSize: true);
      final MultiChildLayoutParentData childParentData = child.parentData;
      childParentData.offset = Offset(x, y);

      y += child.size.height + iVerticalGap;
      height -= child.size.height + iVerticalGap;
    }

    // layout SOUTH
    if (hasChild(BorderLayoutConstraints.SOUTH)) {
      child = getChild(BorderLayoutConstraints.SOUTH);
      child.layout(BoxConstraints(minWidth: 0, maxWidth: width, minHeight: 0, maxHeight: height), parentUsesSize: true);
      final MultiChildLayoutParentData childParentData = child.parentData;
      childParentData.offset = Offset(x, y + height - child.size.height);

      height -= child.size.height + iVerticalGap;
    }

    // layout WEST
    if (hasChild(BorderLayoutConstraints.WEST)) {
      child = getChild(BorderLayoutConstraints.WEST);
      child.layout(BoxConstraints(minWidth: 0, maxWidth: width, minHeight: 0, maxHeight: height), parentUsesSize: true);
      final MultiChildLayoutParentData childParentData = child.parentData;
      childParentData.offset = Offset(x, y);

      x += child.size.width + iHorizontalGap;
      width -= child.size.width + iHorizontalGap;
    }

    // layout EAST
    if (hasChild(BorderLayoutConstraints.EAST)) {
      child = getChild(BorderLayoutConstraints.EAST);
      child.layout(BoxConstraints(minWidth: 0, maxWidth: width, minHeight: 0, maxHeight: height), parentUsesSize: true);
      final MultiChildLayoutParentData childParentData = child.parentData;
      childParentData.offset = Offset(x + width - child.size.width, y);

      width -= child.size.width + iHorizontalGap;
    }

    // layout CENTER
    if (hasChild(BorderLayoutConstraints.CENTER)) {
      child = getChild(BorderLayoutConstraints.CENTER);
      child.layout(BoxConstraints(minWidth: 0, maxWidth: width, minHeight: 0, maxHeight: height), parentUsesSize: true);
      final MultiChildLayoutParentData childParentData = child.parentData;
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


class JVxBorderLayoutId extends ParentDataWidget<JVxBorderLayout> {
  /// Marks a child with a layout identifier.
  ///
  /// Both the child and the id arguments must not be null.
  JVxBorderLayoutId({
    Key key,
    @required this.id,
    @required Widget child
  }) : assert(child != null),
        assert(id != null),
        super(key: key ?? ValueKey<Object>(id), child: child);

  /// An object representing the identity of this child.
  ///
  /// The [id] needs to be unique among the children that the
  /// [CustomMultiChildLayout] manages.
  final Object id;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is MultiChildLayoutParentData);
    final MultiChildLayoutParentData parentData = renderObject.parentData;
    if (parentData.id != id) {
      parentData.id = id;
      final AbstractNode targetParent = renderObject.parent;
      if (targetParent is RenderObject)
        targetParent.markNeedsLayout();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object>('id', id));
  }
}