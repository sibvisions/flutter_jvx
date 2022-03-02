import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import '../../base_wrapper/base_cont_wrapper_state.dart';
import '../../../layout/split_layout.dart';
import '../../../model/component/panel/fl_split_panel_model.dart';
import '../../../model/layout/layout_position.dart';
import '../../../../util/constants/i_color.dart';
import 'fl_split_panel_widget.dart';

class FlSplitPanelWrapper extends BaseCompWrapperWidget<FlSplitPanelModel> {
  const FlSplitPanelWrapper({Key? key, required FlSplitPanelModel model}) : super(key: key, model: model);

  @override
  _FlSplitPanelWrapperState createState() => _FlSplitPanelWrapperState();
}

class _FlSplitPanelWrapperState extends BaseContWrapperState<FlSplitPanelModel> {
  bool canSendAgain = true;

  @override
  void initState() {
    super.initState();

    layoutData.layout = SplitLayout(splitAlignment: model.orientation, leftTopRatio: model.dividerPosition);
    layoutData.children = uiService.getChildrenModels(model.id).map((e) => e.id).toList();

    buildChildren();
    registerParent();
  }

  @override
  receiveNewModel({required FlSplitPanelModel newModel}) {
    layoutData.layout = SplitLayout(splitAlignment: newModel.orientation, leftTopRatio: newModel.dividerPosition);
    super.receiveNewModel(newModel: newModel);

    buildChildren();
    registerParent();
  }

  @override
  Widget build(BuildContext context) {
    var panelWidget = FlSplitPanelWidget(
        model: model,
        layout: layoutData.layout as SplitLayout,
        children: [...children.values.toList(), getDragSlider()]);

    return getPositioned(child: panelWidget);
  }

  Widget getDragSlider() {
    if (layoutData.hasPosition) {
      SplitLayout splitLayout = (layoutData.layout as SplitLayout);
      LayoutPosition currentPosition = layoutData.layoutPosition!;

      dev.log(currentPosition.toString());

      double top = 0.0;
      double left = 0;

      double width = splitLayout.splitterSize;
      double height = splitLayout.splitterSize;

      if (model.orientation == SPLIT_ORIENTATION.HORIZONTAL) {
        width = currentPosition.width;
        top = (currentPosition.height * (splitLayout.leftTopRatio / 100.0)) - (splitLayout.splitterSize / 2);
      } else {
        height = currentPosition.height;
        left = (currentPosition.width * (splitLayout.leftTopRatio / 100.0)) - (splitLayout.splitterSize / 2);
      }

      dev.log("$top, $left | $width, $height");
      return Positioned(
        top: top,
        left: left,
        width: width,
        height: height,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: model.orientation == SPLIT_ORIENTATION.HORIZONTAL ? _verticalDrag : null,
          onVerticalDragEnd: model.orientation == SPLIT_ORIENTATION.HORIZONTAL ? _verticalDragEnd : null,
          onHorizontalDragUpdate: model.orientation == SPLIT_ORIENTATION.VERTICAL ? _horizontalDrag : null,
          onHorizontalDragEnd: model.orientation == SPLIT_ORIENTATION.VERTICAL ? _horizontalDragEnd : null,
          child: Container(
            color: IColorConstants.COMPONENT_DISABLED,
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  void _verticalDragEnd(DragEndDetails pDragDetails) {
    registerParent();
  }

  void _verticalDrag(DragUpdateDetails pDragDetails) {
    final RenderBox container = context.findRenderObject() as RenderBox;
    final pos = container.globalToLocal(pDragDetails.globalPosition);

    SplitLayout splitLayout = (layoutData.layout as SplitLayout);
    splitLayout.leftTopRatio = min(1.0, pos.dy / container.size.height) * 100;

    if (canSendAgain) {
      canSendAgain = false;
      registerParent();

      Future.delayed(SplitLayout.UPDATE_INTERVALL, () {
        canSendAgain = true;
      });
    }
  }

  void _horizontalDragEnd(DragEndDetails pDragDetails) {
    registerParent();
  }

  void _horizontalDrag(DragUpdateDetails pDragDetails) {
    final RenderBox container = context.findRenderObject() as RenderBox;
    final pos = container.globalToLocal(pDragDetails.globalPosition);

    SplitLayout splitLayout = (layoutData.layout as SplitLayout);
    splitLayout.leftTopRatio = min(1.0, pos.dx / container.size.width) * 100;

    if (canSendAgain) {
      canSendAgain = false;
      registerParent();

      Future.delayed(SplitLayout.UPDATE_INTERVALL, () {
        canSendAgain = true;
      });
    }
  }
}
