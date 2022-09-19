import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../layout/split_layout.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/component/panel/fl_split_panel_model.dart';
import '../../../model/layout/layout_position.dart';
import '../../../service/ui/i_ui_service.dart';
import '../../base_wrapper/base_comp_wrapper_state.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import '../../base_wrapper/base_cont_wrapper_state.dart';
import 'fl_split_panel_widget.dart';

class FlSplitPanelWrapper extends BaseCompWrapperWidget<FlSplitPanelModel> {
  const FlSplitPanelWrapper({Key? key, required String id}) : super(key: key, id: id);

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlSplitPanelWrapperState();
}

class _FlSplitPanelWrapperState extends BaseContWrapperState<FlSplitPanelModel> {
  bool canSendAgain = true;

  @override
  void initState() {
    super.initState();

    layoutData.layout = SplitLayout(splitAlignment: model.orientation, leftTopRatio: model.dividerPosition);
    layoutData.children = IUiService().getChildrenModels(model.id).map((e) => e.id).toList();

    buildChildren(pSetStateOnChange: false);
    registerParent();
  }

  @override
  receiveNewModel({required FlSplitPanelModel newModel}) {
    layoutData.layout = SplitLayout(splitAlignment: newModel.orientation, leftTopRatio: newModel.dividerPosition);
    layoutData.children = IUiService().getChildrenModels(model.id).map((e) => e.id).toList();
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

      if (model.orientation == SplitOrientation.HORIZONTAL) {
        width = currentPosition.width;
        top = (currentPosition.height * (splitLayout.leftTopRatio / 100.0)) - (splitLayout.splitterSize / 2);
      } else {
        height = currentPosition.height;
        left = (currentPosition.width * (splitLayout.leftTopRatio / 100.0)) - (splitLayout.splitterSize / 2);
      }

      double splitterWidth = model.orientation == SplitOrientation.VERTICAL ? width : width * 0.3;
      double splitterHeight = model.orientation == SplitOrientation.VERTICAL ? height * 0.3 : height;

      dev.log(splitterWidth.toString());

      dev.log(splitterHeight.toString());

      return Positioned(
        top: top,
        left: left,
        width: width,
        height: height,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: model.orientation == SplitOrientation.HORIZONTAL ? _verticalDrag : null,
          onVerticalDragEnd: model.orientation == SplitOrientation.HORIZONTAL ? _verticalDragEnd : null,
          onHorizontalDragUpdate: model.orientation == SplitOrientation.VERTICAL ? _horizontalDrag : null,
          onHorizontalDragEnd: model.orientation == SplitOrientation.VERTICAL ? _horizontalDragEnd : null,
          child: Container(
            color: Theme.of(context).backgroundColor,
            child: Center(
              child: Container(
                width: splitterWidth,
                height: splitterHeight,
                padding: const EdgeInsets.all(1.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: const ColoredBox(
                    color: Color(0xFFBDBDBD),
                  ),
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
