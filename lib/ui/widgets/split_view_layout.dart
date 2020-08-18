/*import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_flutterclient/ui/widgets/split_view.dart';

enum SplitViewPosition { VIEW1, VIEW2, GRIP }

class SplitViewLayout extends MultiChildRenderObjectWidget {
  final Widget view1;
  final Widget view2;
  final SplitViewMode viewMode;
  final double gripSize;
  final double initialWeight;
  final double positionLimit;

  SplitViewLayout(
      {Key key,
      List<SplitViewLAyoutId> children: const [],
      this.view1,
      this.view2,
      this.viewMode,
      this.gripSize,
      this.initialWeight,
      this.positionLimit})
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
}

class RenderSplitViewLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  RenderSplitViewLayout(
      this.container, this.insMargin, this.iHorizontalGap, this.iVerticalGap,
      {List<RenderBox> children}) {
    addAll(children);
  }
}

class SplitViewLAyoutId extends ParentDataWidget<MultiChildLayoutParentData> {
  /// Marks a child with an BorderLayoutConstraints layout position.
  ///
  /// The child must not be null.
  SplitViewLAyoutId({Key key, this.pConstraints, @required Widget child})
      : assert(child != null),
        super(key: key ?? ValueKey<Object>(pConstraints), child: child);

  /// An BorderLayoutConstraints defines the layout position of this child.
  final SplitViewPosition pConstraints;

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
*/
