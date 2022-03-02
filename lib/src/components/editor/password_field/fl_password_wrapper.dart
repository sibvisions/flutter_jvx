import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../text_field/fl_text_field_wrapper.dart';
import '../../../model/component/text_field/fl_text_field_model.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import 'fl_password_widget.dart';

class FlPasswordFieldWrapper extends BaseCompWrapperWidget<FlTextFieldModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlPasswordFieldWrapper({Key? key, required FlTextFieldModel model}) : super(key: key, model: model);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlPasswordFieldWrapperState createState() => FlPasswordFieldWrapperState();
}

class FlPasswordFieldWrapperState extends FlTextFieldWrapperState<FlTextFieldModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    FlPasswordWidget passwordWidget = FlPasswordWidget(
        model: model,
        valueChanged: valueChanged,
        endEditing: endEditing,
        focusNode: focusNode,
        textController: textController);

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: passwordWidget);
  }
}
