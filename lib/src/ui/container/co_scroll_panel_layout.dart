import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../component/model/component_model.dart';
import '../layout/widgets/co_layout_render_box.dart';
import 'models/container_component_model.dart';

class CoScrollPanelLayout extends MultiChildRenderObjectWidget {
  final CoScrollPanelConstraints preferredConstraints;
  final ContainerComponentModel? container;

  CoScrollPanelLayout(
      {Key? key,
      List<CoScrollPanelLayoutId> children: const [],
      required this.preferredConstraints,
      this.container})
      : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderScrollPanelLayout(this.container);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderScrollPanelLayout renderObject) {
    /// Force Layout, if some of the settings have changed
    if (renderObject.preferredConstraints != this.preferredConstraints) {
      renderObject.preferredConstraints = this.preferredConstraints;
      renderObject.markNeedsLayout();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
  }
}

class RenderScrollPanelLayout extends CoLayoutRenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  RenderBox? child;
  CoScrollPanelConstraints? preferredConstraints;
  ContainerComponentModel? container;

  RenderScrollPanelLayout(this.container, {List<RenderBox>? children}) {
    addAll(children);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiChildLayoutParentData)
      child.parentData = MultiChildLayoutParentData();
  }

  @override
  void performLayout() {
    this.debugInfo = "ScrollLayout in container ${container?.componentId}";

    RenderBox? renderBox = firstChild;
    while (renderBox != null) {
      final MultiChildLayoutParentData childParentData =
          renderBox.parentData as MultiChildLayoutParentData;
      this.child = renderBox;
      this.preferredConstraints =
          childParentData.id as CoScrollPanelConstraints;
      renderBox = childParentData.nextSibling;
    }

    this.preferredLayoutSize = this.constraints.biggest;
    this.maximumLayoutSize = this.constraints.biggest;
    this.minimumLayoutSize = this.constraints.biggest;

    //Size? preferredSize;

    if (child != null) {
      this.layoutRenderBox(child!, BoxConstraints.tightForFinite());

      /*if (child is RenderShiftedBox &&
          (child as RenderShiftedBox).child is CoLayoutRenderBox) {
        CoLayoutRenderBox childLayout =
            (child as RenderShiftedBox).child as CoLayoutRenderBox;

        preferredSize = childLayout.preferredLayoutSize;

        /*if (this.preferredConstraints.componentModel != null)
          print(this.preferredConstraints.componentModel.componentId +
              ";" +
              this.preferredConstraints.componentModel.constraints +
              ";" +
              this.preferredConstraints.componentModel.toString());

        if (child.hasSize) print("child:" + child.size.toString());

        print("pref:" + preferredSize.toString());*/
      }*/

      //print("split_pref:" + preferredConstraints.preferredSize.toString());

      double? newHeight;
      double? newWidth;

      if (child!.size.height <
              preferredConstraints!.parentConstraints.maxHeight &&
          preferredConstraints!.parentConstraints.maxHeight !=
              double.infinity) {
        newHeight = preferredConstraints!.parentConstraints.maxHeight;
      }

      if (this.preferredConstraints?.preferredSize != null &&
          child!.size.width < this.preferredConstraints!.preferredSize!.width) {
        newWidth = this.preferredConstraints!.preferredSize!.width;
      }

      if (newHeight != null || newWidth != null) {
        BoxConstraints newConstraints = BoxConstraints(
            minWidth: (newWidth != null ? newWidth : this.constraints.minWidth),
            maxWidth: (newWidth != null ? newWidth : this.constraints.maxWidth),
            minHeight:
                (newHeight != null ? newHeight : this.constraints.minHeight),
            maxHeight:
                (newHeight != null ? newHeight : this.constraints.maxHeight));

        this.layoutRenderBox(child!, newConstraints);
      } else {
        this.layoutRenderBox(
            child!,
            BoxConstraints(
                minWidth: this.constraints.minWidth,
                maxWidth: this.constraints.maxWidth,
                minHeight: this.constraints.minHeight,
                maxHeight: this.constraints.maxHeight));
      }

      final MultiChildLayoutParentData childParentData =
          child!.parentData as MultiChildLayoutParentData;
      childParentData.offset = Offset(0, 0);
      this.size = this
          .constraints
          .constrainDimensions(child!.size.width, child!.size.height);
    } else {
      this.size = this.constraints.constrainDimensions(
          this.preferredConstraints!.parentConstraints.biggest.width,
          this.preferredConstraints!.parentConstraints.biggest.height);
    }
    //dev.log(
    //    "ScrollLayout in container ${container?.name} (${container?.componentId}) with constraints ${this.constraints}  render size ${this.size.toString()}");
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

class CoScrollPanelLayoutId
    extends ParentDataWidget<MultiChildLayoutParentData> {
  CoScrollPanelLayoutId(
      {Key? key, required this.constraints, required Widget child})
      : super(key: key ?? ValueKey<Object>(constraints), child: child);

  final CoScrollPanelConstraints constraints;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is MultiChildLayoutParentData);
    final MultiChildLayoutParentData parentData =
        renderObject.parentData as MultiChildLayoutParentData;
    if (parentData.id != constraints) {
      parentData.id = constraints;
      final AbstractNode targetParent = renderObject.parent as AbstractNode;
      if (targetParent is RenderObject) targetParent.markNeedsLayout();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object>('id', constraints));
  }

  @override
  Type get debugTypicalAncestorWidgetClass => MultiChildLayoutParentData;
}

class CoScrollPanelConstraints {
  BoxConstraints parentConstraints;
  ComponentModel componentModel;
  Size? preferredSize;

  CoScrollPanelConstraints(this.parentConstraints, this.componentModel,
      [this.preferredSize]);
}
