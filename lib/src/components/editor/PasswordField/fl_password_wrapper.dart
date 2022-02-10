import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import 'fl_password_widget.dart';
import '../TextField/fl_text_field_wrapper.dart';
import '../../../model/component/editor/fl_text_area_model.dart';

class FlTextAreaWrapper extends BaseCompWrapperWidget<FlTextAreaModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlTextAreaWrapper({Key? key, required FlTextAreaModel model}) : super(key: key, model: model);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlTextAreaWrapperState createState() => FlTextAreaWrapperState();
}

class FlTextAreaWrapperState extends FlTextFieldWrapperState<FlTextAreaModel> {
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
