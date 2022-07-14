import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../model/component/check_box/fl_check_box_model.dart';
import '../button/fl_button_wrapper.dart';
import 'fl_check_box_widget.dart';

class FlCheckBoxWrapper extends FlButtonWrapper<FlCheckBoxModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlCheckBoxWrapper({Key? key, required String id}) : super(key: key, id: id);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlCheckBoxWrapperState createState() => FlCheckBoxWrapperState();
}

class FlCheckBoxWrapperState<T extends FlCheckBoxModel> extends FlButtonWrapperState<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    FlCheckBoxWidget checkboxWidget = FlCheckBoxWidget(
      model: model,
      onPress: onPress,
    );

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: checkboxWidget);
  }
}
