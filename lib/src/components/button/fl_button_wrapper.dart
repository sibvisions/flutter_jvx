import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../util/logging/flutter_logger.dart';
import '../../model/command/api/button_pressed_command.dart';
import '../../model/component/button/fl_button_model.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import 'fl_button_widget.dart';

class FlButtonWrapper<T extends FlButtonModel> extends BaseCompWrapperWidget<T> {
  FlButtonWrapper({Key? key, required String id}) : super(key: key, id: id);

  @override
  FlButtonWrapperState createState() => FlButtonWrapperState();
}

class FlButtonWrapperState<T extends FlButtonModel> extends BaseCompWrapperState<T> {
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
    if (currentObjectFocused == null || currentObjectFocused!.parent == null) {
      LOGGER.logI(pType: LOG_TYPE.UI, pMessage: "Button pressed");
      uiService.sendCommand(ButtonPressedCommand(componentName: model.name, reason: "Button has been pressed"));
    } else {
      LOGGER.logI(pType: LOG_TYPE.UI, pMessage: "Button will be pressed");
      currentObjectFocused!.addListener(delayedButtonPress);
      currentObjectFocused!.unfocus();
    }
  }

  void delayedButtonPress() {
    LOGGER.logI(pType: LOG_TYPE.UI, pMessage: "Delayed button pressed");
    uiService.sendCommand(ButtonPressedCommand(componentName: model.name, reason: "Button has been pressed"));
    currentObjectFocused!.removeListener(delayedButtonPress);
    currentObjectFocused = null;
  }
}
