import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_client/util/logging/flutter_logger.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';

import '../../mixin/ui_service_mixin.dart';
import '../../model/command/api/button_pressed_command.dart';
import '../../model/component/button/fl_button_model.dart';
import 'fl_button_widget.dart';

class FlButtonWrapper<T extends FlButtonModel> extends BaseCompWrapperWidget<T> {
  const FlButtonWrapper({Key? key, required T model}) : super(key: key, model: model);

  @override
  FlButtonWrapperState createState() => FlButtonWrapperState();
}

class FlButtonWrapperState<T extends FlButtonModel> extends BaseCompWrapperState<T> with UiServiceMixin {
  /// If anything has a focus, the button pressed event must be added as a listener.
  /// As to send it last.
  FocusNode? currentObjectFocused;

  @override
  Widget build(BuildContext context) {
    final FlButtonWidget buttonWidget = FlButtonWidget(
      model: model,
      onPress: buttonPressed,
    );

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: buttonWidget);
  }

  void buttonPressed() {
    currentObjectFocused = FocusManager.instance.primaryFocus;
    if (currentObjectFocused == null) {
      LOGGER.logI(pType: LOG_TYPE.GENERAL, pMessage: "Button pressed");
      uiService.sendCommand(ButtonPressedCommand(componentId: model.name, reason: "Button has been pressed"));
    } else {
      currentObjectFocused!.addListener(delayedButtonPress);
      currentObjectFocused!.unfocus();
    }
  }

  void delayedButtonPress() {
    LOGGER.logI(pType: LOG_TYPE.GENERAL, pMessage: "Button pressed");
    uiService.sendCommand(ButtonPressedCommand(componentId: model.name, reason: "Button has been pressed"));
    currentObjectFocused!.removeListener(delayedButtonPress);
    currentObjectFocused = null;
  }
}
