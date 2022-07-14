import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../model/component/button/fl_toggle_button_model.dart';
import '../fl_button_wrapper.dart';
import 'fl_toggle_button_widget.dart';

class FlToggleButtonWrapper<T extends FlToggleButtonModel> extends FlButtonWrapper<T> {
  FlToggleButtonWrapper({Key? key, required String id}) : super(key: key, id: id);

  @override
  FlToggleButtonWrapperState createState() => FlToggleButtonWrapperState();
}

class FlToggleButtonWrapperState<T extends FlToggleButtonModel> extends FlButtonWrapperState<T> {
  @override
  Widget build(BuildContext context) {
    final FlToggleButtonWidget buttonWidget = FlToggleButtonWidget(
      model: model,
      onPress: onPress,
    );

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: buttonWidget);
  }
}
