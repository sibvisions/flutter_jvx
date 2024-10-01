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

import '../../../layout/split_layout.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/layout/layout_position.dart';
import '../../../service/storage/i_storage_service.dart';
import '../../base_wrapper/base_comp_wrapper_state.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import '../../base_wrapper/base_cont_wrapper_state.dart';
import 'fl_split_panel_widget.dart';

class FlSplitPanelWrapper extends BaseCompWrapperWidget<FlSplitPanelModel> {
  const FlSplitPanelWrapper({super.key, required super.model});

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlSplitPanelWrapperState();
}

class _FlSplitPanelWrapperState extends BaseContWrapperState<FlSplitPanelModel> {
  final BehaviorSubject subject = BehaviorSubject();

  final ScrollController firstVerticalController = ScrollController();
  final ScrollController firstHorizontalController = ScrollController();
  final ScrollController secondVerticalController = ScrollController();
  final ScrollController secondHorizontalController = ScrollController();

  MouseCursor mouseCursor = MouseCursor.defer;
  double overrideLeftTopRatio = 0.0;
  SplitLayout get splitLayout => (layoutData.layout as SplitLayout);

  _FlSplitPanelWrapperState() : super();

  @override
  void initState() {
    super.initState();

    _createLayout();

    subject.throttleTime(SplitLayout.UPDATE_INTERVAL, leading: false, trailing: true).listen((_) {
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
    return wrapWidget(
      child: MouseRegion(
        cursor: mouseCursor,
        child: FlSplitPanelWidget(
          model: model,
          firstVerticalController: firstVerticalController,
          firstHorizontalController: firstHorizontalController,
          secondVerticalController: secondVerticalController,
          secondHorizontalController: secondHorizontalController,
          layout: layoutData.layout as SplitLayout,
          children: [
            ...children.values,
            getDragSlider(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    firstVerticalController.dispose();
    firstHorizontalController.dispose();
    secondVerticalController.dispose();
    secondHorizontalController.dispose();
    subject.close();
    super.dispose();
  }

  @override
  void registerParent() {
    splitLayout.leftTopRatio = overrideLeftTopRatio;
    super.registerParent();
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
    overrideLeftTopRatio = splitLayout.leftTopRatio;
    layoutData.children =
        IStorageService().getAllComponentsBelowById(pParentId: model.id, pRecursively: false).map((e) => e.id).toList();
  }

  Widget getDragSlider() {
    if (layoutData.hasPosition) {
      LayoutPosition currentPosition = layoutData.layoutPosition!;

      double top = 0.0;
      double left = 0;

      double width = splitLayout.splitterSize;
      double height = splitLayout.splitterSize;

      double leftTopRatio = overrideLeftTopRatio;

      if (model.orientation == SplitOrientation.HORIZONTAL) {
        width = currentPosition.width;
        top = (currentPosition.height * (leftTopRatio / 100.0)) - (splitLayout.splitterSize / 2);
      } else {
        height = currentPosition.height;
        left = (currentPosition.width * (leftTopRatio / 100.0)) - (splitLayout.splitterSize / 2);
      }

      double splitterWidth = model.orientation == SplitOrientation.VERTICAL ? width : width * 0.3;
      double splitterHeight = model.orientation == SplitOrientation.VERTICAL ? height * 0.3 : height;

      return Positioned(
        top: top,
        left: left,
        width: width,
        height: height,
        child: MouseRegion(
          cursor: model.orientation == SplitOrientation.HORIZONTAL
              ? SystemMouseCursors.resizeUpDown
              : SystemMouseCursors.resizeLeftRight,
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
    if (model.orientation == SplitOrientation.HORIZONTAL) {
      mouseCursor = SystemMouseCursors.resizeUpDown;
    } else {
      mouseCursor = SystemMouseCursors.resizeLeftRight;
    }

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

    double positionalPixel = pHorizontal ? pos.dx : pos.dy;
    double containerPixel = pHorizontal ? container.size.width : container.size.height;

    overrideLeftTopRatio = max(0.0, min(1.0, positionalPixel / containerPixel)) * 100;
    subject.add(null);

    setState(() {});
  }
}
