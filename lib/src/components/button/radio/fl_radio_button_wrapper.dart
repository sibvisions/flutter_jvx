import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../model/component/button/fl_radio_button_model.dart';
import '../fl_button_wrapper.dart';
import 'fl_radio_button_widget.dart';

class FlRadioButtonWrapper extends FlButtonWrapper<FlRadioButtonModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlRadioButtonWrapper({super.key, required super.id});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlRadioButtonWrapperState createState() => FlRadioButtonWrapperState();
}

class FlRadioButtonWrapperState<T extends FlRadioButtonModel> extends FlButtonWrapperState<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    FlRadioButtonWidget radioButtonWidget = FlRadioButtonWidget(
      model: model,
      onPress: sendButtonPressed,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: radioButtonWidget);
  }
}
