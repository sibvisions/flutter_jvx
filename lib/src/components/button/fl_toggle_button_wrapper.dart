import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_client/src/model/component/button/fl_toggle_button_model.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';

import '../../mixin/ui_service_mixin.dart';
import '../../model/command/api/button_pressed_command.dart';
import '../../model/component/button/fl_button_model.dart';
import 'fl_toggle_button_widget.dart';

class FlToggleButtonWrapper extends BaseCompWrapperWidget<FlToggleButtonModel> {
  const FlToggleButtonWrapper({Key? key, required FlToggleButtonModel model}) : super(key: key, model: model);

  @override
  _FlToggleButtonWrapperState createState() => _FlToggleButtonWrapperState();
}

class _FlToggleButtonWrapperState extends BaseCompWrapperState<FlToggleButtonModel> with UiServiceMixin {
  @override
  Widget build(BuildContext context) {
    final FlToggleButtonWidget buttonWidget = FlToggleButtonWidget(
      model: model,
      onPress: buttonPressed,
    );

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: buttonWidget);
  }

  void buttonPressed() {
    uiService.sendCommand(ButtonPressedCommand(componentId: model.name, reason: "Button has been pressed"));
  }
}
