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
import 'package:flutter_jvx/src/model/command/api/mouse_clicked_command.dart';
import 'package:flutter_jvx/src/model/command/api/mouse_pressed_command.dart';
import 'package:flutter_jvx/src/model/command/api/mouse_released_command.dart';

import '../../../flutter_jvx.dart';
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
    final FlLabelWidget widget = FlLabelWidget(
      model: model,
      onPress: hasOnPress ? onPress : null,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return wrapWidget(child: widget);
  }

  @override
  Size calculateSize(BuildContext context) {
    if (ParseUtil.isHTML(model.text)) {
      return const Size(400, 100);
    }
    return super.calculateSize(context);
  }

  bool get hasOnPress => model.eventMousePressed || model.eventMouseReleased || model.eventMouseClicked;

  void onPress() {
    if (model.eventMousePressed) {
      ICommandService().sendCommand(
          MousePressedCommand(reason: "Clicked on label ${model.id}:${model.text}", componentName: model.name));
    }

    if (model.eventMouseReleased) {
      ICommandService().sendCommand(
          MouseReleasedCommand(reason: "Clicked on label ${model.id}:${model.text}", componentName: model.name));
    }

    if (model.eventMouseClicked) {
      ICommandService().sendCommand(
          MouseClickedCommand(reason: "Clicked on label ${model.id}:${model.text}", componentName: model.name));
    }
  }
}
