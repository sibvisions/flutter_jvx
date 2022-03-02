import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../mixin/ui_service_mixin.dart';
import '../../../model/component/button/fl_toggle_button_model.dart';

import '../fl_button_wrapper.dart';
import 'fl_toggle_button_widget.dart';

class FlToggleButtonWrapper<T extends FlToggleButtonModel> extends FlButtonWrapper<T> {
  const FlToggleButtonWrapper({Key? key, required T model}) : super(key: key, model: model);

  @override
  FlToggleButtonWrapperState createState() => FlToggleButtonWrapperState();
}

class FlToggleButtonWrapperState<T extends FlToggleButtonModel> extends FlButtonWrapperState<T> with UiServiceMixin {
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
}
