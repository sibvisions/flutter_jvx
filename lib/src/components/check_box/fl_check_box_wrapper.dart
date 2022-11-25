import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../model/component/check_box/fl_check_box_model.dart';
import '../button/radio/fl_radio_button_wrapper.dart';
import 'fl_check_box_widget.dart';

class FlCheckBoxWrapper extends FlRadioButtonWrapper<FlCheckBoxModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlCheckBoxWrapper({super.key, required super.id});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlCheckBoxWrapperState createState() => FlCheckBoxWrapperState();
}

class FlCheckBoxWrapperState<T extends FlCheckBoxModel> extends FlRadioButtonWrapperState<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    FlCheckBoxWidget checkboxWidget = FlCheckBoxWidget(
      focusNode: focusNode,
      model: model,
      onPress: sendButtonPressed,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: checkboxWidget);
  }
}
