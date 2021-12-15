import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_client/src/components/base_wrapper/base_comp_wrapper_state.dart';
import 'package:flutter_client/src/components/base_wrapper/base_comp_wrapper_widget.dart';
import 'package:flutter_client/src/model/component/fl_component_model.dart';

import '../../mixin/ui_service_mixin.dart';
import '../../model/command/api/button_pressed_command.dart';
import '../../model/command/layout/preferred_size_command.dart';
import '../../model/component/button/fl_button_model.dart';
import '../../model/layout/layout_data.dart';
import 'fl_button_widget.dart';

class FlButtonWrapper extends BaseCompWrapperWidget<FlButtonModel> {

  const FlButtonWrapper({Key? key, required FlButtonModel model}) : super(key: key, model: model);

  @override
  _FlButtonWrapperState createState() => _FlButtonWrapperState();
}

class _FlButtonWrapperState extends BaseCompWrapperState<FlButtonModel> with UiServiceMixin {

  @override
  Widget build(BuildContext context) {
    final FlButtonWidget buttonWidget = FlButtonWidget(
      buttonModel: model,
      onPress: buttonPressed,
      width: getWidthForComponent(),
      height: getHeightForComponent(),
    );

    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      postFrameCallback(timeStamp, context);
    });

    return getPositioned(child: buttonWidget);
  }

  void buttonPressed() {
    uiService.sendCommand(ButtonPressedCommand(componentId: model.name, reason: "Button has been pressed"));
  }
}
