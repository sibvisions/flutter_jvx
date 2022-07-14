import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../util/constants/i_color.dart';
import '../../../layout/split_layout.dart';
import '../../../model/component/panel/fl_split_panel_model.dart';
import '../../../model/layout/layout_position.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import '../../base_wrapper/base_cont_wrapper_state.dart';
import 'fl_split_panel_widget.dart';

class FlSplitPanelWrapper extends BaseCompWrapperWidget<FlSplitPanelModel> {
  FlSplitPanelWrapper({Key? key, required String id}) : super(key: key, id: id);

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

    buildChildren(pSetStateOnChange: false);
    registerParent();
  }

  @override
  receiveNewModel({required FlSplitPanelModel newModel}) {
    layoutData.layout = SplitLayout(splitAlignment: newModel.orientation, leftTopRatio: newModel.dividerPosition);
    layoutData.children = uiService.getChildrenModels(model.id).map((e) => e.id).toList();
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
            color: Theme.of(context).backgroundColor,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Container(
                  width: model.orientation == SPLIT_ORIENTATION.VERTICAL ? width : width * 0.3,
                  height: model.orientation == SPLIT_ORIENTATION.VERTICAL ? height * 0.3 : height,
                  color: IColor.darken(IColorConstants.COMPONENT_DISABLED),
                ),
              ),
            ),
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
