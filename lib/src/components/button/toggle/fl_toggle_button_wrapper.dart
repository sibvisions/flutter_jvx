import 'dart:developer';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../model/component/button/fl_toggle_button_model.dart';
import '../fl_button_wrapper.dart';
import 'fl_toggle_button_widget.dart';

class FlToggleButtonWrapper<T extends FlToggleButtonModel> extends FlButtonWrapper<T> {
  const FlToggleButtonWrapper({super.key, required super.id});

  @override
  FlToggleButtonWrapperState createState() => FlToggleButtonWrapperState();
}

class FlToggleButtonWrapperState<T extends FlToggleButtonModel> extends FlButtonWrapperState<T> {
  @override
  Widget build(BuildContext context) {
    log(model.isFocusable.toString());

    final FlToggleButtonWidget buttonWidget = FlToggleButtonWidget(
      onPressDown: (p0) => log("pressed down"),
      onPressUp: (p0) => log("press lifted"),
      onFocusGained: sendFocusGainedCommand,
      onFocusLost: sendFocusLostCommand,
      model: model,
      onPress: sendButtonPressed,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: buttonWidget);
  }
}
