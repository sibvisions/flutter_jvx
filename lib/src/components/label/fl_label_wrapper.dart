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

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../flutter_jvx.dart';
import '../../model/command/api/mouse_clicked_command.dart';
import '../../model/command/api/mouse_pressed_command.dart';
import '../../model/command/api/mouse_released_command.dart';
import '../../util/measure_util.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';

class FlLabelWrapper extends BaseCompWrapperWidget<FlLabelModel> {
  const FlLabelWrapper({super.key, required super.model});

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlLabelWrapperState();
}

class _FlLabelWrapperState extends BaseCompWrapperState<FlLabelModel> {
  _FlLabelWrapperState() : super();

  @override
  initState() {
    super.initState();

    layoutData.isFixedSize = true;
  }

  @override
  Widget build(BuildContext context) {
    Widget widget;

    widget = FlLabelWidget(
      model: model,
      onTap: model.eventMouseClicked ? onClicked : null,
      onDoubleTap: model.eventMouseClicked ? onDoubleClicked : null,
      onTapDown: model.eventMousePressed ? onPressed : null,
      onTapUp: model.eventMouseReleased ? onReleased : null,
      onTapCancel: model.eventMouseReleased && model.eventMousePressed ? onCancelPressed : null,
      wrapper: (widget, padding) => wrapWithBadge(widget ?? ImageLoader.DEFAULT_IMAGE, padding: padding));

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return wrapWidget(child: widget, outlineBadge: false);
  }

  @override
  Size calculateSize(BuildContext context) {
    if (ParseUtil.isHTML(model.text)) {
      EdgeInsets textPadding = FlTextFieldWidget.TEXT_FIELD_PADDING(model.createTextStyle()).copyWith(left: 0, right: 0);
      textPadding = FlLabelWidget.adjustPaddingWithStyles(model, textPadding);

      return MeasureUtil.measureHtml(context, model.text, textPadding).size;
    }

    return super.calculateSize(context);
  }

  void onClicked() {
    if (model.eventMouseClicked) {
      ICommandService().sendCommand(
          MouseClickedCommand(reason: "Clicked on label ${model.id}:${model.text}", componentName: model.name));
    }
  }

  void onDoubleClicked() {
    if (model.eventMouseClicked) {
      ICommandService().sendCommand(
          MouseClickedCommand(reason: "Clicked on label ${model.id}:${model.text}", componentName: model.name));

      ICommandService().sendCommand(
          MouseClickedCommand(reason: "Double clicked on label ${model.id}:${model.text}", componentName: model.name, clickCount: 2));
    }
  }

  void onPressed(TapDownDetails details) {
    if (model.eventMousePressed) {
      ICommandService().sendCommand(
          MousePressedCommand(reason: "Pressed on label ${model.id}:${model.text}", componentName: model.name));
    }
  }

  void onReleased(TapUpDetails details) {
    if (model.eventMouseReleased) {
      ICommandService().sendCommand(
          MouseReleasedCommand(reason: "Released on label ${model.id}:${model.text}", componentName: model.name));
    }
  }

  void onCancelPressed() {
    if (model.eventMouseReleased) {
      ICommandService().sendCommand(
          MouseReleasedCommand(reason: "Released on label ${model.id}:${model.text}", componentName: model.name));
    }
  }
}
