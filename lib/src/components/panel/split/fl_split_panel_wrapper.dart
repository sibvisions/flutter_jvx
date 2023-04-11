/* 
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../flutter_jvx.dart';
import '../../../layout/split_layout.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/layout/layout_position.dart';
import '../../base_wrapper/base_comp_wrapper_state.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import '../../base_wrapper/base_cont_wrapper_state.dart';

class FlSplitPanelWrapper extends BaseCompWrapperWidget<FlSplitPanelModel> {
  const FlSplitPanelWrapper({super.key, required super.model});

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlSplitPanelWrapperState();
}

class _FlSplitPanelWrapperState extends BaseContWrapperState<FlSplitPanelModel> {
  final BehaviorSubject subject = BehaviorSubject();

  final ScrollController firstVerticalcontroller = ScrollController();
  final ScrollController firstHorizontalController = ScrollController();
  final ScrollController secondVerticalController = ScrollController();
  final ScrollController secondHorizontalController = ScrollController();

  MouseCursor mouseCursor = MouseCursor.defer;

  _FlSplitPanelWrapperState() : super();

  @override
  void initState() {
    super.initState();

    _createLayout();

    subject.throttleTime(SplitLayout.UPDATE_INTERVALL, trailing: true).listen((_) {
      registerParent();
    });

    buildChildren(pSetStateOnChange: false);
    registerParent();
  }

  @override
  modelUpdated() {
    _createLayout();

    super.modelUpdated();

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
          firstVerticalcontroller: firstVerticalcontroller,
          firstHorizontalController: firstHorizontalController,
          secondVerticalController: secondVerticalController,
          secondHorizontalController: secondHorizontalController,
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
    firstVerticalcontroller.dispose();
    firstHorizontalController.dispose();
    secondVerticalController.dispose();
    secondHorizontalController.dispose();
    subject.close();
    super.dispose();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _createLayout() {
    layoutData.layout = SplitLayout(
      splitAlignment: model.orientation,
      leftTopRatio: model.dividerPosition,
      calculateLikeScroll: model.isScrollStyle,
    );
    layoutData.children =
        IStorageService().getAllComponentsBelowById(pParentId: model.id, pRecursively: false).map((e) => e.id).toList();
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

      return Positioned(
        top: top,
        left: left,
        width: width,
        height: height,
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeLeftRight,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragStart: model.orientation == SplitOrientation.HORIZONTAL ? _dragStart : null,
            onVerticalDragUpdate: model.orientation == SplitOrientation.HORIZONTAL ? _verticalDrag : null,
            onVerticalDragEnd: model.orientation == SplitOrientation.HORIZONTAL ? _dragEnd : null,
            onHorizontalDragStart: model.orientation == SplitOrientation.VERTICAL ? _dragStart : null,
            onHorizontalDragUpdate: model.orientation == SplitOrientation.VERTICAL ? _horizontalDrag : null,
            onHorizontalDragEnd: model.orientation == SplitOrientation.VERTICAL ? _dragEnd : null,
            child: Container(
              color: Theme.of(context).colorScheme.background,
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

  void _dragStart(DragStartDetails pDragDetails) {
    mouseCursor = SystemMouseCursors.resizeLeftRight;
    setState(() {});
  }

  void _dragEnd(DragEndDetails pDragDetails) {
    mouseCursor = MouseCursor.defer;
    setState(() {});
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
    // model.dividerPosition = splitLayout.leftTopRatio;

    subject.add(null);
  }
}
