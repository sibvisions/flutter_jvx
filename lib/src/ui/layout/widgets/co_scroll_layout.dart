import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterclient/src/ui/ui.dart';

class CoScrollLayout extends SingleChildRenderObjectWidget {
  final BoxConstraints parentConstraints;
  final CoContainerWidget container;

  CoScrollLayout(
      {Key? key,
      required ComponentWidget child,
      required this.parentConstraints,
      required this.container})
      : super(key: key, child: child);

  @override
  RenderScrollLayout createRenderObject(BuildContext context) {
    return RenderScrollLayout(this.parentConstraints, this.container);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderScrollLayout renderObject) {
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

class RenderScrollLayout extends CoLayoutRenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  BoxConstraints? parentConstraints;
  CoContainerWidget? container;

  RenderScrollLayout(this.parentConstraints, this.container,
      {RenderBox? child}) {
    this.child = child;
  }

  @override
  void performLayout() {
    //
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    child!.paint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return child!.hitTest(result, position: position);
  }
}
