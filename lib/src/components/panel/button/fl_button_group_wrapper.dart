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
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../../flutter_jvx.dart';
import '../../../model/component/component_subscription.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/layout/alignments.dart';
import '../../../model/layout/layout_data.dart';
import '../../../model/layout/layout_position.dart';
import '../../../util/jvx_logger.dart';
import '../../base_wrapper/base_comp_wrapper_state.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import '../../base_wrapper/base_cont_wrapper_state.dart';
import '../../button/fl_button_wrapper.dart';
import 'fl_button_group_widget.dart';

class FlButtonGroupWrapper extends BaseCompWrapperWidget<FlPanelModel> {
  const FlButtonGroupWrapper({super.key, required super.model});

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlButtonGroupWrapperState();
}

class _FlButtonGroupWrapperState extends BaseContWrapperState<FlPanelModel> {

  GlobalKey buttonKey = GlobalKey();

  /// The button (children) subscriber
  final Object _buttonSubscriber = Object();

  /// The horizontal alignment
  HorizontalAlignment horizontalAlignment = HorizontalAlignment.LEFT;

  /// The vertical alignment.
  VerticalAlignment verticalAlignment = VerticalAlignment.TOP;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  _FlButtonGroupWrapperState() : super();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    buildChildren(pSetStateOnChange: false);
    registerParent();

    _registerButtons();
  }

  @override
  void dispose()
  {
    super.dispose();

    IUiService().disposeSubscriptions(_buttonSubscriber);
  }

  @override
  modelUpdated() {
    super.modelUpdated();

    buildChildren();
    registerParent();

    _registerButtons();
  }

  @override
  Widget build(BuildContext context) {
    if (model.isScreen && !model.exists) {
      return wrapWidget(context, Container());
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return wrapWidget(context, FlButtonGroupWidget(
      buttonKey: buttonKey,
      model: model,
      horizontalAlignment: model.horizontalAlignment,
      children: childWidgets
    ));
  }

  @override
  Size calculateSize(BuildContext context) {
    double minWidth = 0;
    double minHeight = 0;

    //It's possible that width is defined but height is undefined or vice versa.
    //In both cases, we should try to get the value. Only if no value is defined,
    //throw an error

    Error? eWidth;
    try {
      minWidth = (buttonKey.currentContext?.findRenderObject() as RenderBox).getMaxIntrinsicWidth(double.infinity).ceilToDouble();
    }
    on Error catch (e) {
      eWidth = e;
    }

    Error? eHeight;
    try {
      minHeight = (buttonKey.currentContext?.findRenderObject() as RenderBox).getMaxIntrinsicHeight(double.infinity).ceilToDouble();
    }
    on Error catch (e) {
      eHeight = e;
    }

    if (eWidth != null && eHeight != null) {
      if (FlutterUI.logUI.cl(Lvl.d)) {
        FlutterUI.logUI.d("It's not possible to get the size of widget $runtimeType");
      }
      throw eWidth;
    }

    return Size(minWidth, minHeight);
  }

  LayoutData calculateConstrainedSize(LayoutPosition calcPosition) {
    double calcWidth = layoutData.calculatedSize!.width;
    double calcHeight = layoutData.calculatedSize!.height;

    double positionWidth = calcPosition.width;
    double positionHeight = calcPosition.height;

    bool changed = false;

    // Constraint by width
    if (layoutData.widthConstrains[positionWidth] == null && calcWidth > positionWidth) {
      double newWidth =
      (buttonKey.currentContext?.findRenderObject() as RenderBox).getMaxIntrinsicWidth(max(0.0, positionWidth)).ceilToDouble();

      layoutData.widthConstrains[positionWidth] = newWidth;

      changed = true;
    }

    // Constraint by height
    if (layoutData.heightConstrains[positionHeight] == null && calcHeight > positionHeight) {
      double? newHeight =
      (buttonKey.currentContext?.findRenderObject() as RenderBox).getMaxIntrinsicHeight(max(0.0, positionHeight)).ceilToDouble();

      layoutData.heightConstrains[positionHeight] = newHeight;

      changed = true;
    }

    if (changed) {
      LayoutData layoutDataNew = LayoutData.from(layoutData);
      layoutDataNew.layoutPosition = calcPosition;

      return layoutDataNew;
    }
    else {
      return layoutData;
    }
  }

  Size calculateSize2(BuildContext context) {

    return Size(20, FlTextFieldWidget.TEXT_FIELD_HEIGHT + 4);
  }

  void _registerButtons() {
    IUiService servUi = IUiService();

    servUi.disposeSubscriptions(_buttonSubscriber);

    for (String model in layoutData.children) {

      ComponentSubscription componentSubscription = ComponentSubscription<FlButtonModel>(
        compId: model,
        subbedObj: _buttonSubscriber,
        modelUpdatedCallback: buttonModelUpdated,
      );

      servUi.registerAsLiveComponent(componentSubscription);
    }
  }

  void buttonModelUpdated() {
    setState(() {});
  }

}
