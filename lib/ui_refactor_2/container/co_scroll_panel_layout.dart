import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';

class CoScrollPanelLayout extends MultiChildRenderObjectWidget {
  final BoxConstraints parentConstraints;

  CoScrollPanelLayout(
      {Key key,
      List<CoScrollPanelLayoutId> children: const [],
      this.parentConstraints})
      : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderScrollPanelLayout();
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderScrollPanelLayout renderObject) {
    /// Force Layout, if some of the settings have changed
    if (renderObject.parentConstraints != this.parentConstraints) {
      renderObject.parentConstraints = this.parentConstraints;
      renderObject.markNeedsLayout();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
  }
}

class RenderScrollPanelLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  RenderBox child;
  BoxConstraints parentConstraints;

  RenderScrollPanelLayout({List<RenderBox> children}) {
    addAll(children);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiChildLayoutParentData)
      child.parentData = MultiChildLayoutParentData();
  }

  @override
  void performLayout() {
    RenderBox renderBox = firstChild;
    while (renderBox != null) {
      final MultiChildLayoutParentData childParentData = renderBox.parentData;
      this.child = renderBox;
      this.parentConstraints = childParentData.id;
      renderBox = childParentData.nextSibling;
    }

    if (child != null) {
      child.layout(
          BoxConstraints(
              minWidth: this.constraints.minWidth,
              maxWidth: this.constraints.maxWidth,
              minHeight: this.constraints.minHeight,
              maxHeight: this.constraints.maxHeight),
          parentUsesSize: true);

      if (child.size.height < parentConstraints.maxHeight &&
          parentConstraints.maxHeight != double.infinity) {
        double maxHeight = parentConstraints.maxHeight;

        child.layout(
            BoxConstraints(
                minWidth: this.parentConstraints.minWidth,
                maxWidth: this.parentConstraints.maxWidth,
                minHeight: maxHeight,
                maxHeight: maxHeight),
            parentUsesSize: true);
      }

      final MultiChildLayoutParentData childParentData = child.parentData;
      childParentData.offset = Offset(0, 0);
      this.size = this
          .constraints
          .constrainDimensions(child.size.width, child.size.height);
    } else {
      this.size = this.constraints.constrainDimensions(
          this.parentConstraints.biggest.width,
          this.parentConstraints.biggest.height);
    }
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

class CoScrollPanelLayoutId
    extends ParentDataWidget<MultiChildLayoutParentData> {
  CoScrollPanelLayoutId(
      {Key key, this.parentConstraints, @required Widget child})
      : assert(child != null),
        super(key: key ?? ValueKey<Object>(parentConstraints), child: child);

  final BoxConstraints parentConstraints;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is MultiChildLayoutParentData);
    final MultiChildLayoutParentData parentData = renderObject.parentData;
    if (parentData.id != parentConstraints) {
      parentData.id = parentConstraints;
      final AbstractNode targetParent = renderObject.parent;
      if (targetParent is RenderObject) targetParent.markNeedsLayout();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object>('id', parentConstraints));
  }

  @override
  Type get debugTypicalAncestorWidgetClass => MultiChildLayoutParentData;
}
