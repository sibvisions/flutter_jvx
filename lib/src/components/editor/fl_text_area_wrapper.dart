import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_client/src/components/editor/fl_text_field_wrapper.dart';
import 'package:flutter_client/src/model/component/editor/fl_text_area_model.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import 'fl_text_area_widget.dart';

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
    FlTextAreaWidget textAreaWidget = FlTextAreaWidget(
      key: Key("${model.id}_Widget"),
      model: model,
      endEditing: endEditing,
      valueChanged: valueChanged,
      focusNode: focusNode,
      textController: textController,
    );

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: textAreaWidget);
  }
}
