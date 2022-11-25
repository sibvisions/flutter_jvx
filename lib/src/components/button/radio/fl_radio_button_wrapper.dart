import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../model/component/button/fl_radio_button_model.dart';
import '../fl_button_wrapper.dart';
import 'fl_radio_button_widget.dart';

class FlRadioButtonWrapper<T extends FlRadioButtonModel> extends FlButtonWrapper<T> {
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
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FocusNode focusNode = FocusNode();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        sendFocusGainedCommand();
      } else {
        sendFocusLostCommand();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    focusNode.canRequestFocus = model.isFocusable;

    FlRadioButtonWidget radioButtonWidget = FlRadioButtonWidget(
      focusNode: focusNode,
      model: model,
      onPress: sendButtonPressed,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: radioButtonWidget);
  }

  @override
  void dispose() {
    focusNode.dispose();

    super.dispose();
  }
}
