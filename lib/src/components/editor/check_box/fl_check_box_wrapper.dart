import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_client/src/components/button/fl_toggle_button_wrapper.dart';
import 'package:flutter_client/src/components/editor/check_box/fl_check_box_widget.dart';
import 'package:flutter_client/src/model/component/check_box/fl_check_box_model.dart';

class FlCheckBoxWrapper extends FlToggleButtonWrapper<FlCheckBoxModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlCheckBoxWrapper({Key? key, required FlCheckBoxModel model}) : super(key: key, model: model);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlCheckBoxWrapperState createState() => FlCheckBoxWrapperState();
}

class FlCheckBoxWrapperState<T extends FlCheckBoxModel> extends FlToggleButtonWrapperState<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    FlCheckBoxWidget checkboxWidget = FlCheckBoxWidget(
      model: model,
      onPress: buttonPressed,
    );

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: checkboxWidget);
  }
}
