import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_client/src/components/editor/fl_text_field_widget.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/component/editor/fl_text_field_model.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';

class FlTextFieldWrapper extends BaseCompWrapperWidget<FlTextFieldModel> {
  const FlTextFieldWrapper({Key? key, required FlTextFieldModel model}) : super(key: key, model: model);

  @override
  _FlTextFieldWrapperState createState() => _FlTextFieldWrapperState();
}

class _FlTextFieldWrapperState extends BaseCompWrapperState<FlTextFieldModel> with UiServiceMixin {
  @override
  Widget build(BuildContext context) {
    FlTextFieldWidget textFieldWidget = FlTextFieldWidget(
      key: Key("${model.id}_Widget"),
      model: model,
      endEditing: endEditing,
      valueChanged: valueChanged,
    );

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: textFieldWidget);
  }

  void valueChanged(String pValue) {
    log("Value changed to: " + pValue);
  }

  void endEditing(String pValue) {
    log("Editing ended with: " + pValue);
  }
}
