import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

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
  final BehaviorSubject subject = BehaviorSubject();

  MouseCursor mouseCursor = MouseCursor.defer;

  @override
  void initState() {
    super.initState();

    layoutData.layout = SplitLayout(splitAlignment: model.orientation, leftTopRatio: model.dividerPosition);
    layoutData.children = IUiService().getChildrenModels(model.id).map((e) => e.id).toList();

    subject.throttleTime(SplitLayout.UPDATE_INTERVALL, trailing: true).listen((_) {
      mouseCursor = SystemMouseCursors.resizeLeftRight;
      registerParent();
    });

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
    return getPositioned(
      child: MouseRegion(
        cursor: mouseCursor,
        child: FlSplitPanelWidget(
          model: model,
          layout: layoutData.layout as SplitLayout,
          children: [
            ...children.values.toList(),
            getDragSlider(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    subject.close();
    super.dispose();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

      // TODO: On drag the mouse pointer gets switched back to a normal pointer
      return Positioned(
        top: top,
        left: left,
        width: width,
        height: height,
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeLeftRight,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: model.orientation == SplitOrientation.HORIZONTAL ? _verticalDrag : null,
            onVerticalDragEnd: model.orientation == SplitOrientation.HORIZONTAL ? _dragEnd : null,
            onHorizontalDragUpdate: model.orientation == SplitOrientation.VERTICAL ? _horizontalDrag : null,
            onHorizontalDragEnd: model.orientation == SplitOrientation.VERTICAL ? _dragEnd : null,
            child: Container(
              color: Theme.of(context).backgroundColor,
              child: Center(
                child: Container(
                  width: max(splitterWidth, 0.0),
                  height: max(splitterHeight, 0.0),
                  padding: const EdgeInsets.all(2.0),
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
        ),
      );
    } else {
      return Container();
    }
  }

  void _dragEnd(DragEndDetails pDragDetails) {
    mouseCursor = MouseCursor.defer;
    setState(() {});
    registerParent();
  }

  void _verticalDrag(DragUpdateDetails pDragDetails) {
    _calculateSlider(pDragDetails, false);
  }

  void _horizontalDrag(DragUpdateDetails pDragDetails) {
    _calculateSlider(pDragDetails, true);
  }

  _calculateSlider(DragUpdateDetails pDragDetails, bool pHorizontal) {
    final RenderBox container = context.findRenderObject() as RenderBox;
    final pos = container.globalToLocal(pDragDetails.globalPosition);

    SplitLayout splitLayout = (layoutData.layout as SplitLayout);
    double positionalPixel = pHorizontal ? pos.dx : pos.dy;
    double containerPixel = pHorizontal ? container.size.width : container.size.height;

    splitLayout.leftTopRatio = max(0.0, min(1.0, positionalPixel / containerPixel)) * 100;

    subject.add(null);
  }
}
